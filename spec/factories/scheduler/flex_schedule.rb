# Read about factories at https://github.com/thoughtbot/factory_girl

FactoryGirl.define do
  factory :flex_schedule, :class => 'Scheduler::FlexSchedule' do
    association :person
    %w(sunday monday tuesday wednesday thursday friday saturday).each do |day|
      %w(night day).each do |time|
        send("available_#{day}_#{time}", true)
      end
    end
  end
end
