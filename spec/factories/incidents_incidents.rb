# Read about factories at https://github.com/thoughtbot/factory_girl

FactoryGirl.define do
  factory :incidents_incident, :class => 'Incidents::Incident' do
    chapter nil
    county nil
    incident_number "MyString"
    cas_incident_number "MyString"
    date "2013-06-05"
    city "MyString"
    units_affected 1
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
