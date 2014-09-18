# Read about factories at https://github.com/thoughtbot/factory_girl

FactoryGirl.define do
  factory :territory, :class => 'Incidents::Territory' do
    association :chapter
    name 'My Territory'
  end
end
