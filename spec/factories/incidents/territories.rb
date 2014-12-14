# Read about factories at https://github.com/thoughtbot/factory_girl

FactoryGirl.define do
  factory :territory, :class => 'Incidents::Territory' do
    association :chapter
    name 'My Territory'
    non_disaster_number{Faker::PhoneNumber.phone_number}
    dispatch_number{Faker::PhoneNumber.phone_number}
  end
end
