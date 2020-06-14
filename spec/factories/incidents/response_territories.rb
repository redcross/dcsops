# Read about factories at https://github.com/thoughtbot/factory_girl

FactoryGirl.define do
  factory :response_territory, :class => 'Incidents::ResponseTerritory' do
    association :region
    name 'My Response Territory'
    non_disaster_number{Faker::PhoneNumber.phone_number}
    dispatch_number{Faker::PhoneNumber.phone_number}
  end
end
