require 'spec_helper'

describe Incidents::Ability, :type => :model do

  let(:roles) {[]}
  let(:region) {FactoryGirl.create :region}
  let(:person) {
    double(:person, region: region, id: 10, region_id: region.id).tap{|p|
      allow(p).to receive(:has_role) do |role|
        roles.include? role
      end
    }
  }

  subject { Incidents::Ability.new(person) }

  def grant_role(role)
    roles << role
  end

  def can! *args
    expect(subject.can?(*args)).to be_truthy
  end

  def cannot! *args
    expect(subject.can?(*args)).to be_falsey
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
        let(:today) {region.time_zone.today}

        it "Can't update if the date was more than 5 days ago" do
          incident.status = 'closed'
          incident.date = (today-6)
          cannot! :update, report
        end

        it "Can update if the date was more than 5 days ago but is open" do
          incident.status = 'open'
          incident.date = (today-7)
          can! :update, report
        end

        it "Can submit if the date was less than 5 days ago" do
          incident.date = (today-5)
          can! :update, report
        end
      end
    end
  end

end