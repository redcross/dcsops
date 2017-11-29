class ImportParser
  class_attribute :identity_columns
  class_attribute :column_mappings
  class_attribute :log_progress_every
  class_attribute :preload_identities
  class_attribute :batch_size

  attr_accessor :logger

  self.log_progress_every = 1000
  self.batch_size = 100
  self.preload_identities = true


  def initialize(file, chapter, logger=Rails.logger)
    @csv = file
    @chapter = chapter
    @headers = {}
    @logger = logger
  end

  def header_row; @csv[0]; end

  def column_index(name)
    @headers[name] ||= (header_row.index(name.to_s) || raise("No column for #{name}"))
  end

  def before_import

  end

  def after_import

  end

  def process(&block)
    @callback = block
    setup!

    (1..(@csv.count-1)).to_a.each_slice(self.class.batch_size) do |row_nums|
      identities = row_nums.map{|r| row = @csv[r]; {row: row, identity: parse_columns(row, self.class.identity_columns)} }

      Roster::Person.transaction do
        preload_identities(identities) if self.class.preload_identities

        identities.each do |data|
          row = data[:row]
          identity = data[:identity]
          next unless row.present?

          count_row!          
          attrs = parse_columns row, self.class.column_mappings
          handle_row(identity, attrs, data[:object]) if identity.all?{|k, v| v.present? }
        end
      end
    end

    row_count
  end

  protected

  attr_accessor :row_count

  private

  def setup!
    logger.info "#{self.class.name} Have #{@csv.count} rows"
    @last_period = @start_time = Time.now

    self.row_count = 0    

    before_import
  end

  def count_row!
    self.row_count += 1

    if (row_count % self.class.log_progress_every) == 0 and row_count > 0
      now = Time.now
      total_elapsed = now - @start_time
      total_rate = row_count / total_elapsed
      period_elapsed = now - @last_period
      period_rate = self.class.log_progress_every / period_elapsed
      @last_period = now

      log_rate total_rate, period_rate
    end

    if @callback
      @callback.call self.row_count
    end
  end

  def log_rate(total_rate, period_rate)
    logger.info "#{self.class.name} Processing row #{row_count}/#{@csv.count} at #{'%.1f' % [total_rate]} rows/sec total #{'%.1f' % [period_rate]} rows/sec now"
  end

  def parse_columns(row, columns)
    out = Hash.new
    columns.each do |key, col_name|
      val = row[column_index(col_name)]
      out[key] = val.present? ? val : nil
    end
    out
  end
end
