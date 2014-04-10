# Read about factories at https://github.com/thoughtbot/factory_girl

FactoryGirl.define do
  factory :shift_group, :class => 'Scheduler::ShiftGroup' do
    name 'Group'
    period "daily"
    start_offset 0
    end_offset 24.hours

    association :chapter
  end
end
