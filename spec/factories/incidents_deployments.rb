# Read about factories at https://github.com/thoughtbot/factory_girl

FactoryGirl.define do
  factory :deployment, :class => 'Incidents::Deployment' do
    association :person
    disaster { |f| f.association :disaster, region: f.person.region }
    date_first_seen { |f| f.person.region.time_zone.today - 2 }
    date_last_seen { |f| f.person.region.time_zone.today }
  end
end
