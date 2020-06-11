class Incidents::TerritoryMatcher
  def initialize(incident, territories=nil)
    @incident = incident
    @collection = territories || Incidents::Territory.for_region(@incident.region)
  end

  attr_reader :incident, :collection

  def perform(use_default=false)
    terr = match_territory
    terr ||= default_territory if use_default
    if terr
      incident.territory = terr
    end
    terr.present?
  end

  def match_territory
    match_field(:zip_codes, incident.zip) || match_field(:cities, "#{incident.city}, #{incident.state}") || match_field(:counties, "#{incident.county}, #{incident.state}")
  end

  def default_territory
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