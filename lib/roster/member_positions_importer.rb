class Roster::MemberPositionsImporter < Roster::Importer
  class_attribute :check_dates
  self.check_dates = true
  self.column_mappings = {position_name: 'position_name', position_start: 'position_start_date', position_end: 'position_end_date',
    vc_member_number: 'member_number', first_name: 'first_name', last_name: 'last_name', 
    email: 'email', secondary_email: 'second_email',
    work_phone: 'work_phone', cell_phone: 'cell_phone', home_phone: 'home_phone', alternate_phone: 'alternate_phone',
    gap_primary: 'primary_gap', gap_secondary: 'secondary_gap', gap_tertiary: 'tertiary_gap',
    vc_is_active: 'status_name', second_lang: 'second_language', third_lang: 'third_language',
    vc_last_login: 'last_login', vc_last_profile_update: 'profile_last_updated',
    address1: 'address1', address2: 'address2', city: 'address3', state: 'address4', zip: 'address5', county_name: 'county'
  }

  def positions
    @_positions ||= @chapter.positions.select(&:vc_regex)
  end

  def counties
    @_counties ||= @chapter.counties.select(&:vc_regex)
  end

  def filter person
    filter_email person
    filter_address person
  end

  def filter_email person
    if filter_match? 'email', person.email
      logger.debug "Filtering email '#{person.email}' for #{person.id}:#{person.full_name}"
      filter_hit! 'email'
      person.email = nil
    end
  end

  def filter_address person
    addr = [:address1, :address2, :city, :state, :zip].map{|f| person[f]}.compact.join " "
    if filter_match? 'address', addr
      logger.debug "Filtering address '#{addr}' for #{person.id}:#{person.full_name}"
      filter_hit! 'address'
      person.attributes = {address1: nil, address2: nil, city: nil, state: nil, zip: nil, lat: nil, lng: nil}
    end
  end

  def filter_hit! type
    @filter_hits[type] += 1
  end

  def filter_match? type, val
    (@filters[type] || []).any? {|f| f.pattern.match val }
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

      filter @person

      @person.save!

      @vc_ids_seen << @person.vc_id
    end
  end

  def before_import
    @positions_matcher = Roster::PositionMatcher.new(positions)
    @counties_matcher = Roster::PositionMatcher.new(counties)

    @vc_ids_seen = Set.new
    @filters = DataFilter.where{model == 'Roster::Person'}.group_by(&:field)
    @filter_hits = Hash.new{|h, k| h[k] = 0}

    @num_people = 0
    @num_positions = 0
  end

  def after_import
    # Filter out existing counties in the database before we import.
    @counties_matcher.remove_duplicates Roster::CountyMembership.joins{person}.where{person.chapter_id == my{@chapter}}.pluck(:person_id, :county_id)
    @positions_matcher.remove_duplicates Roster::PositionMembership.joins{person}.where{person.chapter_id == my{@chapter}}.pluck(:person_id, :position_id)

    Roster::CountyMembership.import [:person_id, :county_id], @counties_matcher.matches.to_a
    Roster::PositionMembership.import [:person_id, :position_id], @positions_matcher.matches.to_a

    Roster::Person.where(vc_id: @vc_ids_seen.to_a).update_all :vc_imported_at => Time.now
    deactivated = Roster::Person.for_chapter(@chapter).where{vc_id.not_in(my{@vc_ids_seen.to_a})}.update_all(:vc_is_active => false) if @vc_ids_seen.present?
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
    position_name = person_attrs.delete(:position_name)
    position_name = position_name.strip if position_name
    position_start = person_attrs.delete :position_start
    position_end = person_attrs.delete :position_end

    second_lang = person_attrs.delete :second_lang
    third_lang = person_attrs.delete :third_lang
    county_name = person_attrs.delete :county_name

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
    match_position county_name if county_name.present?
  end

  def match_position position_name
    matched_counties = @counties_matcher.match(position_name, @person.id) 
    matched_positions = @positions_matcher.match(position_name, @person.id)

    unless matched_counties || matched_positions
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
