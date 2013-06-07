# Read about factories at https://github.com/thoughtbot/factory_girl

FactoryGirl.define do
  factory :incidents_cas_incident, :class => 'Incidents::CasIncident' do
    dr_number "MyString"
    cas_incident_number "MyString"
    cas_name "MyString"
    dr_level 1
    is_dr false
    county_name "MyString"
    cases_opened 1
    cases_open 1
    cases_closed 1
    cases_with_assistance 1
    service_only_cases 1
    phantom_cases 1
    last_date_with_open_cases "2013-06-06"
    incident nil
    incident_date "2013-06-06"
    notes "MyText"
    last_import "2013-06-06 16:42:18"
  end
end
