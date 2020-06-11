# Read about factories at https://github.com/thoughtbot/factory_girl

FactoryGirl.define do
  factory :responder_assignment, :class => 'Incidents::ResponderAssignment' do
    association :incident
    person { |ra| ra.association :person, region: ra.incident.region }
    role "responder"
  end
end
