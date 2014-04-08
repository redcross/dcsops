# Read about factories at https://github.com/thoughtbot/factory_girl

FactoryGirl.define do
  factory :notification_subscription, :class => 'Incidents::NotificationSubscription' do
    association :person
    county nil
    notification_type "report"
    frequency 'weekly'
  end
end
