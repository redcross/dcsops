# Read about factories at https://github.com/thoughtbot/factory_girl

FactoryGirl.define do
  factory :shift, :class => 'Scheduler::Shift' do
    name {"Some Shift #{Faker::Name.first_name}"}
    association :shift_territory
    shift_times { |s| [s.association(:shift_time, region: s.shift_territory.region)] }
    shift_category { |s| s.association :shift_category, region: s.shift_territory.region }
    max_signups 1
    min_desired_signups 1
    ordinal 1
    abbrev 'SH'
  end

  factory :shift_with_positions, parent: :shift do
    positions { |s| [s.association(:position, region: s.shift_territory.region)] }
  end
end
