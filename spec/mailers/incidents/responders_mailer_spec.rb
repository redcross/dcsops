require "spec_helper"

describe Incidents::RespondersMailer, :type => :mailer do
  before :each do
    Bitly.stub :client => double(shorten: double(short_url: 'asdf'))
  end

  let(:incident) { FactoryGirl.create :closed_incident }
  let(:assignment) { FactoryGirl.create :responder_assignment, incident: incident }

  describe "assign_email" do
    let(:mail) { Incidents::RespondersMailer.assign_email(assignment) }

    it "renders the headers" do
      expect(mail.subject).to include("DCSOps Incident Assignment")
      expect(mail.to).to eq([assignment.person.email])
      expect(mail.from).to eq(["incidents@dcsops.org"])
    end

    it "renders the body" do
      expect(mail.body.encoded).to match(incident.incident_number)
    end
  end

  describe "assign_sms" do
    let(:mail) { Incidents::RespondersMailer.assign_sms(assignment) }

    it "renders the headers" do
      expect(mail.subject).to eq(nil)
      expect(mail.to).to eq(assignment.person.sms_addresses)
      expect(mail.from).to eq(["sms@dcsops.org"])
    end

    it "renders the body" do
      expect(mail.body.encoded).to match(incident.incident_number)
    end
  end

end
