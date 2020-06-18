# Read about factories at https://github.com/thoughtbot/factory_girl

FactoryGirl.define do
  factory :shift_territory, :class => 'Roster::ShiftTerritory' do
    name { Faker::Address.city }
    association :region
    enabled true
  end
end
