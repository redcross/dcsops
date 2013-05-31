# Read about factories at https://github.com/thoughtbot/factory_girl

FactoryGirl.define do
  factory :shift, :class => 'Scheduler::Shift' do
    name {"Some Shift #{Faker::Name.first_name}"}
    association :shift_group
    max_signups 1
    abbrev 'SH'
  end
end
