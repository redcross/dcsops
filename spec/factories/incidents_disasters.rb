# Read about factories at https://github.com/thoughtbot/factory_girl

FactoryGirl.define do
  factory :disaster, :class => 'Incidents::Disaster' do
    name { "Disaster in #{Faker::Address.state}"}
    dr_number { "%03d-15" % SecureRandom.random_number(1000) }
  end
end
