# Read about factories at https://github.com/thoughtbot/factory_girl

FactoryGirl.define do
  factory :event_log, :class => 'Incidents::EventLog' do
    incident nil
    association :person
    event "note"
    event_time {1.hour.ago}
    message {Faker::Lorem.paragraph}
  end
end
