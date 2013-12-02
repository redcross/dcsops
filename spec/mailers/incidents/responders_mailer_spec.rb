require "spec_helper"

describe Incidents::RespondersMailer do
  before :each do
    Bitly.stub :client => double(shorten: double(short_url: 'asdf'))
  end

  let(:incident) { FactoryGirl.create :closed_incident }
  let(:assignment) { FactoryGirl.create :responder_assignment, incident: incident }

  describe "assign_email" do
    let(:mail) { Incidents::RespondersMailer.assign_email(assignment) }

    it "renders the headers" do
      mail.subject.should eq("ARCBADAT Incident Assignment")
      mail.to.should eq([assignment.person.email])
      mail.from.should eq(["incidents@arcbadat.org"])
    end

    it "renders the body" do
      mail.body.encoded.should match(incident.incident_number)
    end
  end

  describe "assign_sms" do
    let(:mail) { Incidents::RespondersMailer.assign_sms(assignment) }

    it "renders the headers" do
      mail.subject.should eq(nil)
      mail.to.should eq(assignment.person.sms_addresses)
      mail.from.should eq(["sms@arcbadat.org"])
    end

    it "renders the body" do
      mail.body.encoded.should match(incident.incident_number)
    end
  end

end
