class Incidents::ResponseTerritoryMatcher
  def initialize(incident, response_territories=nil)
    @incident = incident
    @collection = response_territories || Incidents::ResponseTerritory.for_region(@incident.region)
  end

  attr_reader :incident, :collection

  def perform(use_default=false)
    terr = match_response_territory
    terr ||= default_response_territory if use_default
    if terr
      incident.response_territory = terr
    end
    terr.present?
  end

  def match_response_territory
    match_field(:zip_codes, incident.zip) || match_field(:cities, "#{incident.city}, #{incident.state}") || match_field(:counties, "#{incident.county}, #{incident.state}")
  end

  def default_response_territory
    collection.detect{|terr| terr.is_default }
  end

  def match_field field, val
    return nil unless val.present?
    val = val.downcase.strip
    collection.detect { |terr|
      (terr.send(field) || []).detect{|str| str.downcase.strip == val}
    }
  end

end