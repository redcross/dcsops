# Read about factories at https://github.com/thoughtbot/factory_girl

FactoryGirl.define do
  factory :partners_partner, :class => 'Partners::Partner' do
    name "MyString"
    address1 "MyString"
    address2 "MyString"
    city "MyString"
    state "MyString"
    zip "MyString"
    lat "9.99"
    lng "9.99"
  end
end
