# Read about factories at https://github.com/thoughtbot/factory_girl

FactoryGirl.define do
  factory :person, :class => 'Roster::Person' do
    association :chapter

    first_name {Faker::Name.first_name}
    last_name {Faker::Name.last_name}
    email {Faker::Internet.email}
    counties { |f| [f.association(:county, chapter: f.chapter)] }
    positions { |f| [f.association(:position, chapter: f.chapter)] }

    primary_county { |f| f.counties.first }

    work_phone {Faker::PhoneNumber.phone_number}
    
  end
end
