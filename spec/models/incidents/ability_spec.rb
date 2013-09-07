require 'spec_helper'

describe Incidents::Ability do

  let(:roles) {[]}
  let(:chapter) {FactoryGirl.create :chapter}
  let(:person) {
    double(:person, chapter: chapter, id: 10).tap{|p|
      p.stub(:has_role) do |role|
        roles.include? role
      end
    }
  }

  subject { Incidents::Ability.new(person) }

  def grant_role(role)
    roles << role
  end

  def can! *args
    subject.can?(*args).should be_true
  end

  def cannot! *args
    subject.can?(*args).should be_false
  end

  context "DatIncident" do
    it {cannot! :create, Incidents::DatIncident}
    it {cannot! :needs_report, Incidents::Incident}
    it {cannot! :mark_invalid, Incidents::Incident}

    context "As incident report submitter" do
      before(:each) {grant_role 'submit_incident_report'}

      it {can! :create, Incidents::DatIncident}
      it {can! :needs_report, Incidents::Incident}
      it {can! :mark_invalid, Incidents::Incident}

      context "Updating an incident report" do
        let(:incident) {FactoryGirl.build :incident}
        let(:report) {FactoryGirl.build :dat_incident, incident: incident}
        let(:today) {chapter.time_zone.today}

        it "Can't update if the date was more than 5 days ago" do
          incident.date = (today-6)
          cannot! :update, report
        end

        it "Can update if the date was less than 5 days ago" do
          incident.date = (today-5)
          can! :update, report
        end
      end
    end
  end

end