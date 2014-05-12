# Read about factories at https://github.com/thoughtbot/factory_girl

FactoryGirl.define do
  factory :incidents_notifications_role_scope, :class => 'Incidents::Notifications::RoleScope' do
    level "MyString"
    value "MyString"
  end
end
