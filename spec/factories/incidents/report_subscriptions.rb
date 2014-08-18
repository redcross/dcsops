# Read about factories at https://github.com/thoughtbot/factory_girl

FactoryGirl.define do
  factory :report_subscription, :class => 'Incidents::ReportSubscription' do
    association :person
    county nil
    report_type "report"
    frequency 'weekly'
  end
end
