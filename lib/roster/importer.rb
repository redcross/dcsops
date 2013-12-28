class Roster::Importer
  class_attribute :identity_columns
  class_attribute :column_mappings
  class_attribute :log_progress_every

  attr_accessor :logger

  self.log_progress_every = 200
  self.identity_columns = {:vc_id => 'account_id'}

  def initialize(file, chapter)
    @csv = CSV.parse file
    @chapter = chapter
    @headers = {}
  end

  def header_row; @csv[0]; end

  def column_index(name)
    @headers[name] ||= (header_row.index(name.to_s) || raise("No column for #{name}"))
  end

  def before_import

  end

  def after_import

  end

  def process
    before_import

    logger.info "#{self.class.name} Have #{@csv.count} rows"
    last_period = start_time = Time.now

    batch_size = 100

    (1..(@csv.count-1)).to_a.each_slice(batch_size) do |row_nums|
      identities = row_nums.map{|r| row = @csv[r]; Hash[self.class.identity_columns.map{|key, col_name| [key, row[column_index(col_name)]]}] }

      Roster::Person.transaction do
        preload_identities(identities)

        row_nums.each do |row_num|
          row = @csv[row_num]
          next unless row.present?

          if (row_num % self.class.log_progress_every) == 0 and row_num > 0
            now = Time.now
            total_elapsed = now- start_time
            total_rate = row_num / total_elapsed
            period_elapsed = now - last_period
            period_rate = self.class.log_progress_every / period_elapsed
            last_period = now

            logger.info "#{self.class.name} Processing row #{row_num}/#{@csv.count} at #{'%.1f' % [total_rate]} rows/sec total #{'%.1f' % [period_rate]} rows/sec now"
            #GC.start
          end

          identity = Hash[self.class.identity_columns.map{|key, col_name| [key, row[column_index(col_name)]]}]

          attrs = Hash[self.class.column_mappings.map{|key, col_name| [key, row[column_index(col_name)]]}.map{|key, val| [key, val.present? ? val : nil]}]

          handle_row(identity, attrs) if identity.all?{|k, v| v.present? }
          yield if block_given?
        end
      end
    end
  end

  def parse_time(val)
    if val.present?
      DateTime.civil(1899,12,30) + val.to_f
    else
      nil
    end
  end

  def is_active_status(status_name)
    ['General Volunteer', 'Employee'].include? status_name
  end

  def preload_identities(identities)
    ids = identities.map{|i| i[:vc_id].to_i }
    @people = Roster::Person.where({chapter_id: @chapter}).where(vc_id: ids).group_by(&:vc_id)
    ids.each do |id|
      @people[id] ||= [Roster::Person.new(chapter: @chapter, vc_id: id)]
    end
  end
end