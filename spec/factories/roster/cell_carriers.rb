FactoryGirl.define do
  factory :cell_carrier, :class => 'Roster::CellCarrier' do
    name "Verizon"
    pager false
    sms_gateway "@vtext.example.com"
  end
end
