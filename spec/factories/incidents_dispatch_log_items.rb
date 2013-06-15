# Read about factories at https://github.com/thoughtbot/factory_girl

FactoryGirl.define do
  factory :incidents_dispatch_log_item, :class => 'Incidents::DispatchLogItem' do
    dispatch_log nil
    action_at "2013-06-14 15:59:14"
    action_type "MyString"
    recipient "MyString"
    operator "MyString"
    result "MyString"
  end
end
