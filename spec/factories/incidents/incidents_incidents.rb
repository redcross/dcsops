# Read about factories at https://github.com/thoughtbot/factory_girl

FactoryGirl.define do
  factory :incident, :class => 'Incidents::Incident' do
    association :chapter
    county { |i| i.association :county, chapter: i.chapter }
    incident_number {"13-#{SecureRandom.random_number(999)}"}
    cas_incident_number {"1-#{SecureRandom.hex(4).upcase}"}
    date "2013-06-05"
    city "MyString"
    num_adults 1
    num_children 1
    num_families 1
    num_cases 1
    incident_type "MyString"
    incident_description "MyString"
    narrative_brief "MyText"
    narrative "MyText"
  end
end
