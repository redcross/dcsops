# Read about factories at https://github.com/thoughtbot/factory_girl

FactoryGirl.define do
  factory :trigger, :class => 'Incidents::Notifications::Trigger' do
    role nil
    event nil
    template "notification"
    use_sms true
  end
end
