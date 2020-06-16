class Roster::MemberPositionsImporter < ImportParser
  include PersonFiltering

  class_attribute :check_dates
  self.check_dates = true
  self.identity_columns = {:vc_id => 'account_id'}
  self.column_mappings = {position_name: 'position_name', position_start: 'position_start_date', position_end: 'position_end_date',
    vc_member_number: 'member_number', first_name: 'first_name', last_name: 'last_name', is_primary: 'is_primary',
    email: 'email', secondary_email: 'second_email',
    work_phone: 'work_phone', cell_phone: 'cell_phone', home_phone: 'home_phone', alternate_phone: 'alternate_phone',
    gap_primary: 'primary_gap', gap_secondary: 'secondary_gap', gap_tertiary: 'tertiary_gap',
    vc_is_active: 'status_name', second_lang: 'second_language', third_lang: 'third_language',
    vc_last_login: 'last_login', vc_last_profile_update: 'profile_last_updated',
    address1: 'street', address2: 'street2', city: 'city', state: 'state', zip: 'zip', county: 'county', rco_id: 'rco_id'
  }

  POSITION_ATTR_NAMES = [:county, :position_name, :position_start, :position_end, :second_lang, :third_lang, :is_primary]

  def positions
    @_positions ||= @region.positions
  end

  def shift_territories
    @_shift_territories ||= @region.shift_territories
  end


  def get_person(object, identity, attrs, all_attrs)
    vc_id = identity[:vc_id].to_i
    is_primary = all_attrs[:is_primary] == 'Yes'
    unless @person and @person.vc_id == vc_id
      status = attrs[:vc_is_active]
      attrs[:vc_is_active] = is_active_status(status)
      @person = object 
      @person ||= Roster::Person.find_or_initialize_by(vc_id: vc_id) if is_importable_status(status)
      if @person.nil? or (@person.new_record? and !is_importable_status(status)) or !is_primary
        #logger.warn "Skipping because inactive and new: #{status}"
        @person = nil
        return
      end

      @num_people += 1

      # Adding region: to the attrs merge should prevent the validates_presence_of: region from doing a db query
      @person.attributes = attrs
      @person.region = @region

      filter @person

      @person.save!

      @vc_ids_seen << @person.vc_id
    end
  end

  def before_import
    @positions_matcher = Roster::PositionMatcher.new(positions)
    @shift_territories_matcher = Roster::PositionMatcher.new(shift_territories)
    @position_names = Hash.new{|h, k| h[k] = 0}

    @vc_ids_seen = Set.new
    @filters = DataFilter.where(model: 'Roster::Person').group_by(&:field)
    @filter_hits = Hash.new{|h, k| h[k] = 0}

    @num_people = 0
    @num_positions = 0
  end

  def after_import
    import_memberships @shift_territories_matcher, Roster::ShiftTerritoryMembership, :shift_territory_id
    import_memberships @positions_matcher, Roster::PositionMembership, :position_id
    Roster::VcImportData.find_or_initialize_by(region_id: @region.id).update_attributes position_data: @position_names, region_id: @region.id

    Roster::Person.where(vc_id: @vc_ids_seen.to_a).update_all :vc_imported_at => Time.now
    deactivated = Roster::Person.for_region(@region).where.not(vc_id: @vc_ids_seen.to_a).update_all(:vc_is_active => false) if @vc_ids_seen.present?
    logger.info "Processed #{@num_people} active users and #{@num_positions} filtered positions"
    logger.info "Deactivated #{deactivated} accounts not received in update"
    logger.info "Filter hits: #{@filter_hits.inspect}"
    logger.info "Geocodes: #{AutoGeocode.geocodes} Failed: #{AutoGeocode.failed}"
  end

  def import_memberships matcher, klass, key
    # Filter out existing shift_territories in the database before we import.
    matcher.remove_duplicates klass.for_region(@region).pluck(:person_id, key)
    klass.import [:person_id, key], matcher.matches.to_a
  end

  def handle_row(identity, attrs, preloaded=nil)
    status = attrs[:vc_is_active]

    # Parse out the date from VC's weird days-since-1900 epoch
    attrs[:vc_last_login] = parse_time attrs[:vc_last_login] if attrs[:vc_last_login]
    attrs[:vc_last_profile_update] = parse_time attrs[:vc_last_profile_update] if attrs[:vc_last_profile_update]

    # Delete these here so get_person doesn't try to assign these attrs
    # to the person model.
    person_attrs = attrs.reject{|k, v| POSITION_ATTR_NAMES.include? k }
    get_person(preloaded, identity, person_attrs, attrs)
    return unless @person

    #logger.debug "Matching #{self.class.name.underscore.split("_").first} #{position_name} for #{identity.inspect}"
    @num_positions += 1
    match_positions attrs if process_row?(attrs)
  end

  def match_positions attrs
    position_name = attrs.delete(:position_name)
    position_name = position_name.strip if position_name
    position_start = attrs.delete :position_start
    position_end = attrs.delete :position_end

    if check_dates
      return unless position_end.nil? or parse_time(position_end) > Time.now
      return unless position_start.nil? or parse_time(position_start) < Time.now
    end

    match_position_named position_name
  end

  def match_position_named position_name
    @position_names[position_name] += 1
    matched_shift_territories = @shift_territories_matcher.match(position_name, @person.id) 
    matched_positions = @positions_matcher.match(position_name, @person.id)

    unless !logger.debug? || matched_shift_territories || matched_positions
      logger.debug "Didn't match a record for item #{position_name}"
    end
  end

  def filter_regex
    return @_filter_regex if defined?(@_filter_regex)
    if ENV['POSITIONS_FILTER']
      @_filter_regex = Regexp.new(ENV['POSITIONS_FILTER'])
    elsif @region.vc_position_filter.present?
      @_filter_regex = Regexp.new(@region.vc_position_filter)
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

  def parse_time(val)
    if val.present?
      days_since_2000 = val.to_f - 36526
      DateTime.civil(2000, 01, 01) + days_since_2000
    else
      nil
    end
  end

  def is_active_status(status_name)
    ['General Volunteer', 'General Partner Member', 'Employee', 'NHQ Reserve Employee', 'AmeriCorps (Affiliated)'].include? status_name
  end

  def is_importable_status(status_name)
    is_active_status(status_name) || (@region.roster_import_prospective_members && (status_name == 'Prospective Volunteer'))
  end

  def preload_identities(identities)
    ids = identities.group_by{|i| i[:identity][:vc_id].to_i }
    people = Roster::Person.for_region(@region).where(vc_id: ids.keys).to_a
    people.each do |person|
      ids[person.vc_id].first[:object] = person
    end
  end

end
