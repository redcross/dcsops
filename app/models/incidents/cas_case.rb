class Incidents::CasCase < ApplicationRecord
  belongs_to :cas_incident, class_name: "Incidents::CasIncident", inverse_of: :cases

  include AutoGeocode
  self.geocode_columns = %w(address city state)

  def self.[] case_number
    find_by case_number: case_number
  end

  def to_param
    case_number
  end
end
