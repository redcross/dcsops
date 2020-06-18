class Incidents::CasPromoter

  def self.promote! cas_incident, region=nil
    new(cas_incident, region).promote!
  end

  def initialize cas_incident, region=nil
    @cas_incident = cas_incident
    @region = region
  end

  attr_reader :cas_incident

  def region
    @region ||= Roster::Region.all.detect{|ch| ch.cas_region_codes_array.include? cas_incident.region_code}
  end

  def promote!
    return if cas_incident.incident
    return unless region

    cas_incident.class.transaction do
      inc = cas_incident.build_incident

      inc.date = cas_incident.incident_date
      inc.status = 'closed'
      inc.incident_number = "19-#{cas_incident.id}"
      inc.region = region
      inc.num_adults = cas_incident.num_clients
      inc.num_children = 0
      inc.num_families = cas_incident.cases.count
      inc.num_cases = cas_incident.cases.count

      inc.cas_event_number = cas_incident.cas_incident_number
      inc.shift_territory = region.shift_territories.find_by(name: (cas_incident.county || 'Region')) || region.shift_territories.find_by(name: 'Region')
      return unless inc.shift_territory

      geocode_incident inc

      if inc.save validate: false
        cas_incident.save validate: false
      end
    end
  end

  def geocode_incident inc
    kase = cas_incident.cases.first
    geocode = if kase
      inc.address = kase.address
      inc.city = kase.city
      inc.state = kase.state

      Geokit::Geocoders::GoogleGeocoder.geocode( [inc.address, inc.city, inc.state].join(", "))
    elsif cas_incident.county
      Geokit::Geocoders::GoogleGeocoder.geocode "#{cas_incident.county}, CA, USA"
    end

    if geocode
      inc.take_location_from geocode
    end
  end
end