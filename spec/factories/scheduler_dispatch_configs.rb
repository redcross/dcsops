# Read about factories at https://github.com/thoughtbot/factory_girl

FactoryGirl.define do
  factory :scheduler_dispatch_config, :class => 'Scheduler::DispatchConfig' do
    name { Faker::Address.city }
    county nil
    backup_first nil
    backup_second nil
    backup_third nil
  end
end
