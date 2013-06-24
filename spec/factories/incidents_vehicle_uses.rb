# Read about factories at https://github.com/thoughtbot/factory_girl

FactoryGirl.define do
  factory :incidents_vehicle_use, :class => 'Incidents::VehicleUse' do
    vehicle nil
    incident nil
  end
end
