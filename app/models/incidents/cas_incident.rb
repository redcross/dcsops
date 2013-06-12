class Incidents::CasIncident < ActiveRecord::Base
  belongs_to :incident, class_name: 'Incidents::Incident'
  has_many :cases, class_name: 'Incidents::CasCase'
  alias :cas_cases :cases

  validates :incident_id, :cas_incident_number, :dr_number, uniqueness: {allow_blank: true, allow_nil: true}

  def is_dr
    dr_number != cas_incident_number
  end

  def to_param
    cas_incident_number
  end

  # For Debug Purposes
  def create_incident_from_cas!
    return if incident_id

    self.class.transaction do
      inc = self.build_incident
      inc.incident_number = "19-#{self.id}"
      inc.chapter = Roster::Chapter.first
      inc.num_adults = self.num_clients
      inc.num_children = 0
      inc.num_families = self.cases.count
      inc.num_cases = self.cases.count
      #inc.units_affected = self.cases.count

      inc.cas_incident_number = cas_incident_number

      kase = self.cases.first
      if kase
        inc.address = kase.address
        inc.city = kase.city
        inc.state = kase.state
        inc.cross_street = "_"
        inc.zip = "_"

        res = Geokit::Geocoders::GoogleV3Geocoder.geocode( [inc.address, inc.city, inc.state].join(", "))
        if res
          (inc.lat, inc.lng) = res.lat, res.lng
        end
      elsif county_name
        res = Geokit::Geocoders::GoogleV3Geocoder.geocode "#{county_name}, CA, USA"
        if res
          (inc.lat, inc.lng) = res.lat, res.lng
        end
      else
        return
      end
      inc.county = Roster::County.find_by_name (county_name || 'Chapter')
      return unless inc.county

      #inc.incident_call_type = 'hot'
      #inc.incident_type = 'fire'
      #inc.team_lead_id = Roster::Person.where(last_name: 'Laxson').first.id
      inc.date = incident_date

      if inc.save
        self.save
      end
    end
  end

end
