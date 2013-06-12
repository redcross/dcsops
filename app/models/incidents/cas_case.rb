class Incidents::CasCase < ActiveRecord::Base
  belongs_to :cas_incident, class_name: "Incidents::CasIncident"

  def to_param
    case_number
  end
end
