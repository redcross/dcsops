require 'spec_helper'

describe Incidents::IncidentReportFiled do
  before(:each) do
    @incident = FactoryGirl.create :incident
    @person = FactoryGirl.create :person
  end

  it "should notify someone subscribed to incident_report" do
    Incidents::NotificationSubscription.create! person: @person, county: @incident.area, notification_type: 'incident_report'

    Incidents::IncidentsMailer.should_receive(:incident_report_filed).with(@incident, @person, true).and_return(double :deliver => true)

    Incidents::IncidentReportFiled.new(@incident, true).save
  end
end