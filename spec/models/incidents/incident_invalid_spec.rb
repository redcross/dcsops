require 'spec_helper'

describe Incidents::IncidentInvalid do
  before(:each) do
    @person = FactoryGirl.create :person
    @incident = FactoryGirl.create :incident, chapter: @person.chapter
  end

  it "should notify someone subscribed to incident_report" do
    Incidents::NotificationSubscription.create! person: @person, county: @incident.area, notification_type: 'incident_report'

    Incidents::IncidentsMailer.should_receive(:incident_invalid).with(@incident, @person).and_return(double :deliver => true)

    Incidents::IncidentInvalid.new(@incident).save
  end

  it "should not notify someone from another chapter" do
    Incidents::NotificationSubscription.create! person: @person, county: @incident.area, notification_type: 'incident_report'
    other_person = FactoryGirl.create :person

    Incidents::NotificationSubscription.create! person: other_person, county: nil, notification_type: 'incident_report'

    Incidents::IncidentsMailer.stub :incident_invalid do |inc, person|
      inc.should == @incident
      person.should_not == other_person
      double deliver: true
    end

    Incidents::IncidentInvalid.new(@incident).save
  end
end