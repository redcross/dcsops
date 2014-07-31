# Read about factories at https://github.com/thoughtbot/factory_girl

FactoryGirl.define do
  factory :deployment, :class => 'Incidents::Deployment' do
    association :person
    disaster { |f| f.association :disaster, chapter: f.person.chapter }
    date_first_seen { |f| f.person.chapter.time_zone.today - 2 }
    date_last_seen { |f| f.person.chapter.time_zone.today }
  end
end
