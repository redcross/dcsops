# Read about factories at https://github.com/thoughtbot/factory_girl

FactoryGirl.define do
  factory :shift, :class => 'Scheduler::Shift' do
    name {"Some Shift #{Faker::Name.first_name}"}
    association :county
    shift_groups { |s| [s.association(:shift_group, region: s.county.region)] }
    shift_category { |s| s.association :shift_category, region: s.county.region }
    max_signups 1
    min_desired_signups 1
    ordinal 1
    abbrev 'SH'
  end

  factory :shift_with_positions, parent: :shift do
    positions { |s| [s.association(:position, region: s.county.region)] }
  end
end
