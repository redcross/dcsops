# Read about factories at https://github.com/thoughtbot/factory_girl

FactoryGirl.define do
  factory :initial_incident_report, :class => 'Incidents::InitialIncidentReport' do

  end

  factory :complete_initial_incident_report, parent: :initial_incident_report do
    estimated_units 20
    estimated_individuals 50
    trend 'stable'
    triggers ['budget']
    expected_services ['shelter', 'food']
    significant_media false
    safety_concerns false
    weather_concerns true
  end

end
