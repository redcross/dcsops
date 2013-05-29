# Read about factories at https://github.com/thoughtbot/factory_girl

FactoryGirl.define do
  factory :person, :class => 'Roster::Person' do
    first_name {Faker::Name.first_name}
    last_name {Faker::Name.last_name}
    email {Faker::Internet.email}
    counties { |f| [f.association( :county)] }
    positions { |f| [f.association( :position)] }

    work_phone {Faker::PhoneNumber.phone_number}
  end
end
