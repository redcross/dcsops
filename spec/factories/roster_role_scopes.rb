# Read about factories at https://github.com/thoughtbot/factory_girl

FactoryGirl.define do
  factory :roster_role_scope, :class => 'Roster::RoleScope' do
    role nil
    scope "MyString"
  end
end
