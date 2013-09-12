require 'spec_helper'

describe Incidents::IncidentInvalid do
  before(:each) do
    @incident = FactoryGirl.create :incident
    @person = FactoryGirl.create :person
  end

  it "should notify someone subscribed to incident_report" do
    Incidents::NotificationSubscription.create! person: @person, county: @incident.county, notification_type: 'incident_report'

    Incidents::IncidentsMailer.should_receive(:incident_invalid).with(@incident, @person).and_return(double :deliver => true)

    Incidents::IncidentInvalid.new(@incident).save
  end
end