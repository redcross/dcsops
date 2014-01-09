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
      Incidents::IncidentMissingReport.should_receive(:new).with(@incident).and_return(double :save => true)
      expect {
        subject.invoke
      }.to change{@incident.reload.last_no_incident_warning}
    end

    it "should send a reminder if the incident was last pinged a while ago" do
      @incident.update_attribute :created_at, 24.hours.ago
      @incident.update_attribute :last_no_incident_warning, 13.hours.ago
      Incidents::IncidentMissingReport.should_receive(:new).with(@incident).and_return(double :save => true)
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
      }
    end

    it "should not send a reminder if the incident has been marked invalid" do
      @incident.update_attribute :created_at, 24.hours.ago
      @incident.update_attribute :incident_type, 'invalid'
      Incidents::IncidentMissingReport.should_not_receive(:new)
      expect {
        subject.invoke
      }
    end

    it "should not send a reminder if the incident was pinged recently" do
      @incident.update_attribute :created_at, 24.hours.ago
      @incident.update_attribute :last_no_incident_warning, 2.hours.ago
      Incidents::IncidentMissingReport.should_not_receive(:new)
      expect {
        subject.invoke
      }
    end

    it "should not send a reminder if the incident has an incident report" do
      @incident.update_attribute :created_at, 24.hours.ago
      @incident.update_attribute :last_no_incident_warning, 24.hours.ago
      FactoryGirl.create :dat_incident, incident: @incident
      Incidents::IncidentMissingReport.should_not_receive(:new)
      expect {
        subject.invoke
      }
    end
  end

  describe "incidents_periodic:send_weekly_report" do
    before(:each) do
      @incident = FactoryGirl.create :incident
      @person = FactoryGirl.create :person, chapter: @incident.chapter
      @person.chapter.update_attributes incidents_report_send_automatically: true
    end

    it "should send the weekly report to a person with a subscription" do
      Delorean.time_travel_to Date.current.at_beginning_of_week.in_time_zone
      sub = Incidents::NotificationSubscription.create! person: @person, county: nil, notification_type: 'report', frequency: 'weekly'

      Incidents::ReportMailer.should_receive(:report_for_date_range).with(@person.chapter, @person, sub.range_to_send).and_return(double :deliver => true)
      subject.invoke
    end
  end
end