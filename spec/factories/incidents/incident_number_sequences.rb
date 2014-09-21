FactoryGirl.define do
  factory :incident_number_sequence, :class => 'Incidents::NumberSequence' do
    name 'My Sequence'
    current_year '2014'
    current_number 0
    format '%<fy_short>02d-%<number>04d'
  end
end
