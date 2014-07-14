require "spec_helper"

describe Incidents::ReportMailer, :type => :mailer do
  let(:from_address) {["incidents@dcsops.org"]}
  let(:chapter) { FactoryGirl.create :chapter }
  let(:person) { FactoryGirl.create :person, chapter: chapter }

  describe "report" do
    let(:mail) { Incidents::ReportMailer.report(chapter, person) }

    it "renders the headers" do
      expect(mail.subject).to match("ARCBA Disaster Operations")
      expect(mail.to).to eq([person.email])
      expect(mail.from).to eq(from_address)
    end

    it "renders the body" do
      expect(mail.body.encoded).to match("ARCBA Disaster Operations")
    end

    it "is multipart" do
      expect(mail.parts.count).to eq(2)
    end

    # I'm not sure what the right way to test the subtitle helper is
    # right now, so we'll examine it as output in the subject and this
    # can be moved when I find a better way.
    describe "#subtitle" do
      let(:mail) { Incidents::ReportMailer.report_for_date_range(chapter, person, @date_range) }

      it "Displays week when the week starts on monday and is 7 days long" do
        @date_range = Date.civil(2014,1,6)..Date.civil(2014,1,12)
        expect(mail.subject).to match("Week of January 6 2014")
      end

      it "Displays the day when only one day long" do
        date = Date.civil(2014,1,9)
        @date_range = date..date
        expect(mail.subject).to match("Thursday, January 9")
      end

      it "Displays short date range otherwise" do
        @date_range = Date.civil(2014,1,10)..Date.civil(2014,1,12)
        expect(mail.subject).to match("Fri, Jan 10 to Sun, Jan 12")
      end
    end
    
  end

end
