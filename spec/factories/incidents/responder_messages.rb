# Read about factories at https://github.com/thoughtbot/factory_girl

FactoryGirl.define do
  factory :responder_message, :class => 'Incidents::ResponderMessage' do
    chapter nil
    person nil
    responder_assignment nil
    in_reply_to nil
    direction "MyString"
    local_number "MyString"
    remote_number "MyString"
    message "MyString"
    acknowledged false
  end

  factory :incoming_responder_message, parent: :responder_message do
    direction "incoming"
  end
end
