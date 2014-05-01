# Read about factories at https://github.com/thoughtbot/factory_girl

FactoryGirl.define do
  factory :case, :class => 'Incidents::Case' do
    cas_case_number "1-xxxxx"
    first_name {Faker::Name.first_name}
    last_name {Faker::Name.last_name}
    unit { Faker::Address.building_number }
    address { Faker::Address.street_address }

    city {Faker::Address.city}
    state {Faker::Address.state}
    zip {Faker::Address.zip}
    
    lat {Faker::Address.latitude}
    lng {Faker::Address.longitude}

    phone_number {Faker::PhoneNumber.phone_number}
    num_adults 1
    num_children 1
  end

  factory :case_with_assistance, parent: :case do
    total_amount "9.99"

    case_assistance_items { |c| (0..3).map{ c.association :case_assistance_item }}
  end
end
