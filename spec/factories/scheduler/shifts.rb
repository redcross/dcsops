# Read about factories at https://github.com/thoughtbot/factory_girl

FactoryGirl.define do
  factory :shift, :class => 'Scheduler::Shift' do
    name {"Some Shift #{Faker::Name.first_name}"}
    association :county
    shift_groups { |s| [s.association(:shift_group, chapter: s.county.chapter)] }
    shift_category { |s| s.association :shift_category, chapter: s.county.chapter }
    max_signups 1
    min_desired_signups 1
    ordinal 1
    abbrev 'SH'
    recommendation_score 1
  end

  factory :shift_with_positions, parent: :shift do
    positions { |s| [s.association(:position, chapter: s.county.chapter)] }
  end

  factory :shift_with_high_recommendation, parent: :shift do
    recommendation_score 5
  end
end
