require 'spec_helper'

describe Incidents::IncidentReportFiled do
  before(:each) do
    @person = FactoryGirl.create :person
    @incident = FactoryGirl.create :closed_incident, chapter: @person.chapter
  end

  it "should notify someone subscribed to incident_report" do
    Incidents::NotificationSubscription.create! person: @person, county: @incident.area, notification_type: 'incident_report'

    Incidents::IncidentsMailer.should_receive(:incident_report_filed).with(@incident, @person, true).and_return(double :deliver => true)

    Incidents::IncidentReportFiled.new(@incident, true).save
  end
end