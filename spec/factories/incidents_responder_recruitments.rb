# Read about factories at https://github.com/thoughtbot/factory_girl

FactoryGirl.define do
  factory :incidents_responder_recruitment, :class => 'Incidents::ResponderRecruitment' do
    incident nil
    person nil
    response "MyString"
    outbound_message nil
    inbound_message nil
  end
end
