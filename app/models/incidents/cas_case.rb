class Incidents::CasCase < ActiveRecord::Base
  belongs_to :cas_incident, class_name: "Incidents::CasIncident"
end
