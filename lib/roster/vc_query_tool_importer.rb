require 'csv'

class Roster::VcQueryToolImporter
  include ::NewRelic::Agent::Instrumentation::ControllerInstrumentation

  attr_accessor :logger
  attr_accessor :row_counter

  def initialize(logger=nil, row_counter=nil)
    self.logger = logger || Rails.logger
    self.row_counter = row_counter
  end

  def query_mappings
    {#members: 'Active Members', 
      positions: 'Active Members Positions', 
      qualifications: 'Active Members Qualifications', 
      usage: 'Active Members Usage'
    }
  end

  def importer_mappings
    {#members: MembersImporter, 
      positions: MemberPositionsImporter, 
      qualifications: QualificationsImporter,
      usage: UsageImporter
    }
  end

  def import(chapter, queries=query_mappings.keys)
    client = VcQuery.new chapter.vc_username, chapter.vc_password
    client.logger = self.logger

    Roster::Person.transaction do

      if queries.include?(:positions) || queries.include?(:qualifications)
        Roster::PositionMembership.destroy_all_for_chapter(chapter)
        Roster::CountyMembership.destroy_all_for_chapter(chapter)
      end

      importer_mappings.slice(*queries).each do |name, klass|
        logger.info "Processing import for #{name}"
        if Rails.env.development? and true
          csv = Rails.cache.fetch "vc-query-#{name}-#{chapter.id}" do
            xls = client.execute_query query_mappings[name]
            XlsToCsv.convert xls
          end
        else
          xls = client.execute_query query_mappings[name]
          csv = XlsToCsv.convert xls
        end

        handler = klass.new(csv, chapter)
        xls = nil; csv = nil; # Get rid of these 6MB+ objects
        handler.logger = logger
        handler.process { self.row_counter.row! if self.row_counter }
      end
    end
  end
  add_transaction_tracer :import, category: :task
end

class Importer
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

    after_import
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

class MemberPositionsImporter < Importer

  class_attribute :check_dates
  self.check_dates = true
  self.column_mappings = {position_name: 'position_name', position_start: 'position_start_date', position_end: 'position_end_date',
    vc_member_number: 'member_number', first_name: 'first_name', last_name: 'last_name', 
    email: 'email', secondary_email: 'second_email',
    work_phone: 'work_phone', cell_phone: 'cell_phone', home_phone: 'home_phone', alternate_phone: 'alternate_phone',
    gap_primary: 'primary_gap', gap_secondary: 'secondary_gap', gap_tertiary: 'tertiary_gap',
    vc_is_active: 'status_name', second_lang: 'second_language', third_lang: 'third_language',
    vc_last_login: 'last_login', vc_last_profile_update: 'profile_last_updated'}

  def positions
    @_positions ||= @chapter.positions.select(&:vc_regex)
  end

  def counties
    @_counties ||= @chapter.counties.select(&:vc_regex)
  end



  def get_person(identity, attrs, all_attrs)
    vc_id = identity[:vc_id].to_i
    unless @person and @person.vc_id == vc_id
      attrs[:vc_is_active] = is_active_status(attrs[:vc_is_active])
      @person = @people[vc_id].first #Roster::Person.where({chapter_id: @chapter}.merge(identity)).first_or_initialize
      if @person.new_record? and !attrs[:vc_is_active]
        #logger.warn "Skipping because inactive and new: #{attrs.inspect}"
        @person = nil
        return
      end

      @num_people += 1

      # Adding chapter: to the attrs merge should prevent the validates_presence_of: chapter from doing a db query
      @person.attributes = attrs.merge({chapter: @chapter})

      if (@filters['email'] || []).any? {|f| f.pattern.match @person.email }
        logger.debug "Filtering email '#{@person.email}' for #{@person.id}:#{@person.full_name}"
        @filter_hits['email'] += 1
        @person.email = nil
      end

      @person.save!

      @vc_ids_seen << @person.vc_id
    end
  end

  def before_import
    @people_positions = Hash.new { |hash, key| hash[key] = Set.new }
    @people_counties = Hash.new { |hash, key| hash[key] = Set.new }
    @positions_to_import = []
    @counties_to_import = []
    @vc_ids_seen = []
    @filters = DataFilter.where{model == 'Roster::Person'}.group_by(&:field)
    @filter_hits = Hash.new{|h, k| h[k] = 0}

    @num_people = 0
    @num_positions = 0

    Roster::CountyMembership.joins{person}.where{person.chapter_id == my{@chapter}}.each do |mem|
      @people_counties[mem.person_id] << mem.county_id
    end

    Roster::PositionMembership.joins{person}.where{person.chapter_id == my{@chapter}}.each do |mem|
      @people_positions[mem.person_id] << mem.position_id
    end
  end

  def after_import
    Roster::CountyMembership.import @counties_to_import
    Roster::PositionMembership.import @positions_to_import
    Roster::Person.where(vc_id: @vc_ids_seen).update_all :vc_imported_at => Time.now
    deactivated = Roster::Person.for_chapter(@chapter).where{vc_id.not_in(my{@vc_ids_seen})}.update_all(:vc_is_active => false) if @vc_ids_seen.present?
    logger.info "Processed #{@num_people} active users and #{@num_positions} filtered positions"
    logger.info "Deactivated #{deactivated} accounts not received in update"
    logger.info "Filter hits: #{@filter_hits.inspect}"
  end

  def handle_row(identity, attrs)
    # Parse out the date from VC's weird days-since-1900 epoch
    attrs[:vc_last_login] = parse_time attrs[:vc_last_login] if attrs[:vc_last_login]
    attrs[:vc_last_profile_update] = parse_time attrs[:vc_last_profile_update] if attrs[:vc_last_profile_update]

    # Delete these here so get_person doesn't try to assign these attrs
    # to the person model.  But we want them there so process_row can use above.
    person_attrs = attrs.dup
    position_name = person_attrs.delete :position_name
    position_name.strip! if position_name
    position_start = person_attrs.delete :position_start
    position_end = person_attrs.delete :position_end

    second_lang = person_attrs.delete :second_lang
    third_lang = person_attrs.delete :third_lang

    get_person(identity, person_attrs, attrs)
    return unless @person
    return unless process_row?(attrs)

    if check_dates
      return unless position_end.nil? or parse_time(position_end) > Time.now
      return unless position_start.nil? or parse_time(position_start) < Time.now
    end

    #logger.debug "Matching #{self.class.name.underscore.split("_").first} #{position_name} for #{identity.inspect}"
    @num_positions += 1

    match_position position_name
    match_position second_lang if second_lang.present?
    match_position third_lang if third_lang.present?
  end

  def match_position position_name
    matched = false
    counties.each do |county|
      if county.vc_regex.match position_name
        unless @people_counties[@person.id].include? county.id
          @counties_to_import << @person.county_memberships.build(county: county)
          @people_counties[@person.id] << county.id
          matched=true
          break
        end
      end
    end

    positions.each do |position|
      if position.vc_regex.match position_name
        unless @people_positions[@person.id].include? position.id
          @positions_to_import << @person.position_memberships.build(position: position)
          @people_positions[@person.id] << position.id
          matched=true
          break
        end
      end
    end

    unless matched
      logger.debug "Didn't match a record for item #{position_name}"
    end
  end

  def filter_regex
    return @_filter_regex if defined?(@_filter_regex)
    if ENV['POSITIONS_FILTER']
      @_filter_regex = Regexp.new(ENV['POSITIONS_FILTER'])
     elsif @chapter.vc_position_filter.present?
      @_filter_regex = Regexp.new(@chapter.vc_position_filter)
    end
  end

  def process_row? attrs
    position_name = attrs[:position_name]
    if filter_regex
      position_name.present? and (position_name =~ filter_regex)
    else
      position_name.present?
    end
  end

end

class QualificationsImporter < MemberPositionsImporter
  self.column_mappings = {position_name: 'qualification_name'}
  self.check_dates = false

  def get_person(identity, attrs, all_attrs)
    unless process_row?(all_attrs)
      @person = nil
      return
    end
    vc_id = identity[:vc_id].to_i
    unless @person and @person.vc_id == vc_id
      attrs[:vc_is_active] = is_active_status(attrs[:vc_is_active])
      @person = @people[vc_id].first
    end
  end

  def process_row?(attrs)
    attrs[:position_name].present?
  end
end

class UsageImporter < Importer
  def before_import
    @filters = DataFilter.where{model == 'Roster::Person'}.group_by(&:field)
    @filter_hits = Hash.new{|h, k| h[k] = 0}
  end

  def handle_row(identity, attrs)
    #return unless self.class.loaded_ids.include?(attrs[:vc_id])
    #status = attrs.delete(:status_name)
    #return unless is_active_status(status)
    vc_id = identity[:vc_id].to_i
    person = @people[vc_id].first
    if person && person.persisted? # Don't be creating anything
      #logger.debug "Usage for #{identity.inspect} is #{attrs.inspect}"
      person.attributes = attrs.merge({chapter: @chapter})

            # Check this against any/all filters
      addr = [:address1, :address2, :city, :state, :zip].map{|f| person[f]}.compact.join " "
      if (@filters['address'] || []).any? { |f| f.pattern.match addr  }
        logger.debug "Filtering address '#{addr}' for #{person.id}:#{person.full_name}"
        @filter_hits['address'] += 1
        person.attributes = {address1: nil, address2: nil, city: nil, state: nil, zip: nil, lat: nil, lng: nil}
      end

      person.save!
    end
  end

  def after_import
    logger.info "Filter hits: #{@filter_hits.inspect}"
  end

  self.column_mappings = {address1: 'address1', address2: 'address2', city: 'address3', state: 'address4', zip: 'address5'}
end
