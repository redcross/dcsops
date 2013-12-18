class Incidents::CasCase < ActiveRecord::Base
  belongs_to :cas_incident, class_name: "Incidents::CasIncident"

  include AutoGeocode
  self.geocode_columns = %w(address city state)

  def to_param
    case_number
  end
end
