# Read about factories at https://github.com/thoughtbot/factory_girl

FactoryGirl.define do
  factory :person, :class => 'Roster::Person' do
    region { |f| f.association :region }

    first_name {Faker::Name.first_name}
    last_name {Faker::Name.last_name}
    email {Faker::Internet.email}
    counties { |f| [f.association(:county, region: f.region)] }
    positions { |f| [f.association(:position, region: f.region)] }

    primary_county { |f| f.counties.first }

    work_phone {Faker::PhoneNumber.phone_number}
    
  end
end
