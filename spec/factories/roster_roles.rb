# Read about factories at https://github.com/thoughtbot/factory_girl

FactoryGirl.define do
  factory :role, :class => 'Roster::Role' do
    name "MyString"
    grant_name "MyString"
  end
end
