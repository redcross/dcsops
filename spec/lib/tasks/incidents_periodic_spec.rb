require 'spec_helper'

describe "incidents_periodic:send_reminders" do
  include_context "rake"

  its(:prerequisites) { should eq(['send_missing_incident_report'])}
end

describe "" do
  include_context "rake"
  let(:task_name) { self.class.description }

  before(:each) do
    
  end

  after(:each) do
    Delorean.back_to_1985
  end

  describe "incidents_periodic:send_no_incident_report" do

    before(:each) do
      @incident = FactoryGirl.create :incident
      @log = FactoryGirl.create :dispatch_log, incident: @incident
    end

    it "should send a reminder if the incident has a log and was created a while ago" do
      @incident.update_attribute :created_at, 24.hours.ago
      Incidents::IncidentMissingReport.should_receive(:new).with(@incident).and_return(stub :save => true)
      expect {
        subject.invoke
      }.to change{@incident.reload.last_no_incident_warning}
    end

    it "should send a reminder if the incident was last pinged a while ago" do
      @incident.update_attribute :created_at, 24.hours.ago
      @incident.update_attribute :last_no_incident_warning, 13.hours.ago
      Incidents::IncidentMissingReport.should_receive(:new).with(@incident).and_return(stub :save => true)
      expect {
        subject.invoke
      }.to change{@incident.reload.last_no_incident_warning}
    end

    it "should not send a reminder if the incident doesn't have a log" do
      @incident.update_attribute :created_at, 24.hours.ago
      @incident.dispatch_log = nil
      @incident.save
      Incidents::IncidentMissingReport.should_not_receive(:new)
      expect {
        subject.invoke
      }.to_not change{@incident.reload.last_no_incident_warning}
    end

    it "should not send a reminder if the incident was created recently" do
      @incident.update_attribute :created_at, 5.hours.ago
      Incidents::IncidentMissingReport.should_not_receive(:new)
      expect {
        subject.invoke
      }.to_not change{@incident.reload.last_no_incident_warning}
    end

    it "should not send a reminder if the incident was pinged recently" do
      @incident.update_attribute :created_at, 24.hours.ago
      @incident.update_attribute :last_no_incident_warning, 2.hours.ago
      Incidents::IncidentMissingReport.should_not_receive(:new)
      expect {
        subject.invoke
      }.to_not change{@incident.reload.last_no_incident_warning}
    end

    it "should not send a reminder if the incident has an incident report" do
      @incident.update_attribute :created_at, 24.hours.ago
      @incident.update_attribute :last_no_incident_warning, 24.hours.ago
      FactoryGirl.create :dat_incident, incident: @incident
      Incidents::IncidentMissingReport.should_not_receive(:new)
      expect {
        subject.invoke
      }.to_not change{@incident.reload.last_no_incident_warning}
    end
  end
end