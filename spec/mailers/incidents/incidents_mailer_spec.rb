require "spec_helper"

describe Incidents::IncidentsMailer do
  let(:from_address) {["incidents@arcbadat.org"]}

  before(:each) do
    @chapter = FactoryGirl.create :chapter
  end

  describe "weekly" do
    let(:mail) { Incidents::IncidentsMailer.weekly(@chapter) }

    it "renders the headers" do
      mail.subject.should match("ARCBA Disaster Operations")
      #mail.to.should eq(["to@example.org"])
      mail.from.should eq(from_address)
    end

    it "renders the body" do
      mail.body.encoded.should match("ARCBA Disaster Operations")
    end

    it "is multipart" do
      mail.parts.count.should == 2
    end
  end

  describe "no_incident_report" do
    let(:report) { stub :incident, incident_number: "12-345", county: stub(:county, name: 'County'), created_at: Time.zone.now}
    let(:mail) { Incidents::IncidentsMailer.no_incident_report(report) }

    it "renders the headers" do
      mail.subject.should eq("Missing Incident Report")
      mail.from.should eq(from_address)
    end

    it "should be to the county designated contact" do
      pending
      mail.to.should eq(["to@example.org"])
    end

    it "renders the body" do
      mail.body.encoded.should match("An incident number was created for your")
    end
  end

  #describe "orphan_cas" do
  #  let(:mail) { Incidents::IncidentsMailer.orphan_cas }
#
  #  it "renders the headers" do
  #    mail.subject.should eq("Orphan cas")
  #    mail.to.should eq(["to@example.org"])
  #    mail.from.should eq(from_address)
  #  end
#
  #  it "renders the body" do
  #    mail.body.encoded.should match("Hi")
  #  end
  #end

end
