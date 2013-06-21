# Read about factories at https://github.com/thoughtbot/factory_girl

FactoryGirl.define do
  factory :incidents_notification_subscription, :class => 'Incidents::NotificationSubscription' do
    person nil
    county nil
    notification_type "MyString"
  end
end
