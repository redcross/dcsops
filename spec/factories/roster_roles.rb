# Read about factories at https://github.com/thoughtbot/factory_girl

FactoryGirl.define do
  factory :roster_role, :class => 'Roster::Role' do
    name "MyString"
    code "MyString"
    role_scope "MyText"
  end
end
