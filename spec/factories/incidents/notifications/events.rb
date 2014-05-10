# Read about factories at https://github.com/thoughtbot/factory_girl

FactoryGirl.define do
  factory :event, :class => 'Incidents::Notifications::Event' do
    chapter nil
    name "MyString"
    description "MyString"
    event_type "event"
  end
end
