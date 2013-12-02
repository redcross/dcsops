# Read about factories at https://github.com/thoughtbot/factory_girl

FactoryGirl.define do
  factory :responder_assignment, :class => 'Incidents::ResponderAssignment' do
    association :person
    association :incident
    role "team_lead"
  end
end
