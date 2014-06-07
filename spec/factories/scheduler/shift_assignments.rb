# Read about factories at https://github.com/thoughtbot/factory_girl

FactoryGirl.define do
  factory :shift_assignment, :class => 'Scheduler::ShiftAssignment' do
    date {Date.tomorrow}
    association :person
    shift { |f| f.association :shift, county: f.person.counties.first, positions: f.person.positions}
    shift_group { |f| f.shift.shift_groups.first }
  end
end
