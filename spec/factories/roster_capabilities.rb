# Read about factories at https://github.com/thoughtbot/factory_girl

FactoryGirl.define do
  factory :capability, :class => 'Roster::Capability' do
    name "MyString"
    grant_name "MyString"
  end
end
