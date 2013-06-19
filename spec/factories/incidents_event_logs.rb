# Read about factories at https://github.com/thoughtbot/factory_girl

FactoryGirl.define do
  factory :incidents_event_log, :class => 'Incidents::EventLog' do
    incident nil
    person nil
    event "MyString"
    event_time "2013-06-16 18:23:28"
    message "MyText"
  end
end
