require 'spec_helper'

describe Incidents::IncidentCreated do
  before(:each) do
    @incident = FactoryGirl.create :incident
    @person = FactoryGirl.create :person, chapter: @incident.chapter
  end

  it "should notify someone subscribed to new_incident" do
    Incidents::NotificationSubscription.create! person: @person, county: @incident.area, notification_type: 'new_incident'

    Incidents::IncidentsMailer.should_receive(:new_incident).with(@incident, @person).and_return(double :deliver => true)

    Incidents::IncidentCreated.new(@incident).save
  end
end