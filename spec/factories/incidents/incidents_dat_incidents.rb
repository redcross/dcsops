# Read about factories at https://github.com/thoughtbot/factory_girl

FactoryGirl.define do
  factory :dat_incident, :class => 'Incidents::DatIncident' do
    association :incident

    incident_type 'fire'
    incident_call_type 'hot'
    structure_type 'apartment'

    num_adults 1
    num_children 1
    num_families 1

    units_affected 10
    units_minor 10
    units_major 10
    units_destroyed 10

    num_people_injured 5
    num_people_hospitalized 5
    num_people_deceased 5

    responder_notified 2.hours.ago
    responder_arrived 1.hour.ago
    responder_departed Time.zone.now

    comfort_kits_used 1
    blankets_used 10

    address { Faker::Address.street_address }
    cross_street {Faker::Address.street_name }
    city {Faker::Address.city}
    state {Faker::Address.state}
    zip {Faker::Address.zip}
    
    lat {Faker::Address.latitude}
    lng {Faker::Address.longitude}
  end
end
