# Read about factories at https://github.com/thoughtbot/factory_girl

FactoryGirl.define do
  factory :county, :class => 'Roster::County' do
    name { Faker::Address.city }
    association :region
    enabled true
  end
end
