FactoryGirl.define do
  factory :vehicle, class: 'Logistics::Vehicle' do
    category 'suv'
    name {Faker::Name.last_name}
  end
end
