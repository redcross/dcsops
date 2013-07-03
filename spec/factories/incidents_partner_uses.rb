# Read about factories at https://github.com/thoughtbot/factory_girl

FactoryGirl.define do
  factory :incidents_partner_use, :class => 'Incidents::PartnerUse' do
    incident nil
    partner nil
    role "MyString"
    hotel_rate "9.99"
    hotel_rooms 1
  end
end
