require 'spec_helper'

describe Incidents::IncidentMissingReport do
  before(:each) do
    @incident = FactoryGirl.create :incident
    @person = FactoryGirl.create :person
  end

  it "should notify someone subscribed to new_incident" do
    Incidents::NotificationSubscription.create! person: @person, county: @incident.county, notification_type: 'missing_report'

    Incidents::IncidentsMailer.should_receive(:no_incident_report).with(@incident, @person).and_return(stub :deliver => true)

    Incidents::IncidentMissingReport.new(@incident).save
  end

  it "should notify someone with a dispatch role for that day" do
    date = @incident.created_at.in_time_zone(@incident.chapter.time_zone).to_date
    @p2 = FactoryGirl.create :person, chapter: @incident.chapter, counties: [@incident.county]
    @group = FactoryGirl.create :shift_group, period: 'daily', start_offset: 0, end_offset: 86400, chapter: @p2.chapter
    @shift = FactoryGirl.create :shift, shift_group: @group, positions: @p2.positions, county: @p2.counties.first, dispatch_role: 1
    @ass = FactoryGirl.create :shift_assignment, shift: @shift, date: date, person: @p2

    Incidents::IncidentsMailer.should_receive(:no_incident_report).with(@incident, @ass.person).and_return(stub :deliver => true)

    Incidents::IncidentMissingReport.new(@incident).save
  end

  it "should not notify someone without a dispatch role for that day" do
    date = @incident.created_at.in_time_zone(@incident.chapter.time_zone).to_date
    @p2 = FactoryGirl.create :person, chapter: @incident.chapter, counties: [@incident.county]
    @group = FactoryGirl.create :shift_group, period: 'daily', start_offset: 0, end_offset: 86400, chapter: @p2.chapter
    @shift = FactoryGirl.create :shift, shift_group: @group, positions: @p2.positions, county: @p2.counties.first, dispatch_role: nil
    @ass = FactoryGirl.create :shift_assignment, shift: @shift, date: date, person: @p2

    Incidents::IncidentsMailer.should_not_receive(:no_incident_report)

    Incidents::IncidentMissingReport.new(@incident).save
  end
end