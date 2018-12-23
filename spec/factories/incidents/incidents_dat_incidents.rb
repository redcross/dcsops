# Read about factories at https://github.com/thoughtbot/factory_girl

FactoryGirl.define do
  factory :dat_incident, :class => 'Incidents::DatIncident' do
    association :incident

    completed_by { |f| f.association :person, region: f.incident.region}
    vehicle_uses { |f| [Incidents::VehicleUse.new( vehicle: f.association(:vehicle))]}

    incident_call_type 'hot'
    structure_type 'apartment'

    units_not_livable 10
    units_livable 10
    units_affected 10
    units_minor 10
    units_major 10
    units_destroyed 10

    num_people_injured 5
    num_people_hospitalized 5
    num_people_deceased 5

    services ['immediate']
    #resources( {'comfort_kits' => 1, 'blankets' => 10})
    comfort_kits 1
    blankets 10

  end
end
