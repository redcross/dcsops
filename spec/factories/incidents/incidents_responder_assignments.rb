# Read about factories at https://github.com/thoughtbot/factory_girl

FactoryGirl.define do
  factory :responder_assignment, :class => 'Incidents::ResponderAssignment' do
    association :incident
    person { |ra| ra.association :person, chapter: ra.incident.chapter }
    role "responder"
  end
end
