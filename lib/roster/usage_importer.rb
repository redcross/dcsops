class Roster::UsageImporter < Roster::Importer
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