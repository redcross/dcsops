require "spec_helper"

describe Incidents::ReportMailer do
  let(:from_address) {["incidents@arcbadat.org"]}
  let(:person) { FactoryGirl.create :person }
  let(:log_items) { [double(:dispatch_log_item, action_at: Time.zone.now, action_type: 'Dial', recipient: '', result: '')] }

  before(:each) do
    @chapter = FactoryGirl.create :chapter
  end

  describe "report" do
    let(:mail) { Incidents::ReportMailer.report(@chapter, person) }

    it "renders the headers" do
      mail.subject.should match("ARCBA Disaster Operations")
      mail.to.should eq([person.email])
      mail.from.should eq(from_address)
    end

    it "renders the body" do
      mail.body.encoded.should match("ARCBA Disaster Operations")
    end

    it "is multipart" do
      mail.parts.count.should == 2
    end
  end
end
