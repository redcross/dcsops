class Incidents::VehicleUse < ApplicationRecord
  belongs_to :vehicle, class_name: "Logistics::Vehicle"
  belongs_to :incident, class_name: 'Incidents::DatIncident'

  after_initialize :debug_me

  def debug_me
    #byebug
  end
end
