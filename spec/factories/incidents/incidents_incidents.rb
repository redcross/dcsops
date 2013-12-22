# Read about factories at https://github.com/thoughtbot/factory_girl

FactoryGirl.define do
  factory :raw_incident, :class => 'Incidents::Incident' do
    date "2013-06-05"
    status 'open'
    area { |i| i.association :county, chapter: i.chapter }
    incident_number {"13-#{SecureRandom.random_number(999)}"}
  end

  factory :incident, parent: :raw_incident do
    association :chapter
    
    cas_incident_number {"1-#{SecureRandom.hex(4).upcase}"}
    
    num_adults 1
    num_children 1
    num_families 1
    num_cases 1
    incident_type "fire"
    incident_description "MyString"
    narrative_brief "MyText"
    narrative "MyText"

    address { Faker::Address.street_address }
    cross_street {Faker::Address.street_name }
    city {Faker::Address.city}
    state {Faker::Address.state}
    zip {Faker::Address.zip}
    county {Faker::Address.country}
    
    lat {Faker::Address.latitude}
    lng {Faker::Address.longitude}
  end

  factory :closed_incident, parent: :incident do
    status 'closed'
    association :dat_incident 
    team_lead {|f| f.association :responder_assignment, person: f.association( :person)}
    before(:create) {|i| 
        i.event_logs.build event: 'dat_received', event_time: 2.hours.ago
        i.event_logs.build event: 'dat_on_scene', event_time: 1.hours.ago
        i.event_logs.build event: 'dat_departed_scene', event_time: Time.now
    }
  end
end
