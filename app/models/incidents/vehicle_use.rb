class Incidents::VehicleUse < ActiveRecord::Base
  belongs_to :vehicle, class_name: "Logistics::Vehicle"
  belongs_to :incident, class_name: 'Incidents::DatIncident'
end
