# Read about factories at https://github.com/thoughtbot/factory_girl

FactoryGirl.define do
  factory :cas_incident, :class => 'Incidents::CasIncident' do
    dr_number {"1-#{SecureRandom.hex 4}"}
    cas_incident_number {|i| i.dr_number}
    cas_name "Some Incident Some Date"
    dr_level nil
    is_dr false
    county_name "MyString"
    cases_opened 1
    cases_open 1
    cases_closed 1
    cases_with_assistance 1
    cases_service_only 1
    phantom_cases 0
    last_date_with_open_cases "2013-06-06"
    incident nil
    incident_date "2013-06-06"
    notes "MyText"
    last_import "2013-06-06 16:42:18"
  end
end
