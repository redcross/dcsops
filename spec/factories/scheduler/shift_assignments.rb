# Read about factories at https://github.com/thoughtbot/factory_girl

FactoryGirl.define do
  factory :shift_assignment, :class => 'Scheduler::ShiftAssignment' do
    date {Date.tomorrow}
    association :person
    shift { |f| f.association :shift, shift_territory: f.person.shift_territories.first, positions: f.person.positions}
    shift_time { |f| f.shift.shift_times.first }
  end
end
