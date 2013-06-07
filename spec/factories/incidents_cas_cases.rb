# Read about factories at https://github.com/thoughtbot/factory_girl

FactoryGirl.define do
  factory :incidents_cas_case, :class => 'Incidents::CasCase' do
    cas_incident nil
    case_number "MyString"
    num_clients 1
    family_name "MyString"
    case_last_updated "2013-06-06"
    case_opened "2013-06-06"
    case_language "MyString"
    narrative "MyText"
    address "MyString"
    city "MyString"
    state "MyString"
    post_incident_plans "MyString"
    notes "MyText"
    last_import "2013-06-06 16:45:04"
  end
end
