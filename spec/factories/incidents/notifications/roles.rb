# Read about factories at https://github.com/thoughtbot/factory_girl

FactoryGirl.define do
  factory :notification_role, :class => 'Incidents::Notifications::Role' do
    name "Test Role"
    scope "MyString"
  end
end
