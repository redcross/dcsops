# Read about factories at https://github.com/thoughtbot/factory_girl

FactoryGirl.define do
  factory :shift_category, :class => 'Scheduler::ShiftCategory' do
    chapter nil
    name "Shift Category #{SecureRandom.random_number 20}"
    show true
  end
end
