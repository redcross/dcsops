require "spec_helper"

describe Incidents::IncidentsMailer do
  describe "weekly" do
    let(:mail) { Incidents::IncidentsMailer.weekly }

    it "renders the headers" do
      mail.subject.should eq("Weekly")
      mail.to.should eq(["to@example.org"])
      mail.from.should eq(["from@example.com"])
    end

    it "renders the body" do
      mail.body.encoded.should match("Hi")
    end
  end

  describe "no_incident_report" do
    let(:mail) { Incidents::IncidentsMailer.no_incident_report }

    it "renders the headers" do
      mail.subject.should eq("No incident report")
      mail.to.should eq(["to@example.org"])
      mail.from.should eq(["from@example.com"])
    end

    it "renders the body" do
      mail.body.encoded.should match("Hi")
    end
  end

  describe "orphan_cas" do
    let(:mail) { Incidents::IncidentsMailer.orphan_cas }

    it "renders the headers" do
      mail.subject.should eq("Orphan cas")
      mail.to.should eq(["to@example.org"])
      mail.from.should eq(["from@example.com"])
    end

    it "renders the body" do
      mail.body.encoded.should match("Hi")
    end
  end

end
