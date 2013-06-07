# Read about factories at https://github.com/thoughtbot/factory_girl

FactoryGirl.define do
  factory :incidents_responder_assignment, :class => 'Incidents::ResponderAssignment' do
    person nil
    incident nil
    role "MyString"
    response "MyString"
  end
end
