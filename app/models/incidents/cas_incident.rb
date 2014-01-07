class Incidents::CasIncident < ActiveRecord::Base
  belongs_to :incident, class_name: 'Incidents::Incident'
  belongs_to :chapter, class_name: 'Roster::Chapter'
  has_many :cases, class_name: 'Incidents::CasCase'
  alias :cas_cases :cases

  #validates :incident_id, :cas_incident_number, :dr_number, uniqueness: {allow_blank: true, allow_nil: true}

  scope :to_link_for_chapter, -> (chapter) {
    where{(incident_id == nil) & (chapter_id == chapter)}.order{incident_date.desc}
  }

  def is_dr
    dr_number != cas_incident_number
  end

  def to_param
    cas_incident_number
  end

  # For Debug Purposes
  def create_incident_from_cas!(chapter=nil)
    return if incident_id

    self.class.transaction do
      inc = self.build_incident
      inc.status = 'closed'
      inc.incident_number = "19-#{self.id}"
      inc.chapter = chapter || Roster::Chapter.all.detect{|ch| ch.cas_chapter_code_array.include? self.chapter_code}
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

        res = Geokit::Geocoders::GoogleGeocoder3.geocode( [inc.address, inc.city, inc.state].join(", "))
        if res
          (inc.lat, inc.lng) = res.lat, res.lng
          inc.county = res.district.gsub(' County', '') if res.district
          inc.zip = res.zip
        end
      elsif county_name
        res = Geokit::Geocoders::GoogleGeocoder3.geocode "#{county_name}, CA, USA"
        if res
          (inc.lat, inc.lng) = res.lat, res.lng
          inc.county = county_name
        end
      else
        return
      end
      inc.area = Roster::County.find_by_name(county_name || 'Chapter') || Roster::County.find_by_name('Chapter')
      return unless inc.area

      #inc.incident_call_type = 'hot'
      #inc.incident_type = 'fire'
      #inc.team_lead_id = Roster::Person.where(last_name: 'Laxson').first.id
      inc.date = incident_date

      if inc.save validate: false
        self.save validate: false
      end
    end
  end

end
