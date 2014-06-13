require "spec_helper"

describe Incidents::Notifications::Mailer do
  let(:from_address) {["incidents@dcsops.org"]}
  let(:person) { FactoryGirl.build_stubbed :person }
  let(:log_items) { [double(:dispatch_log_item, action_at: Time.zone.now, action_type: 'Dial', recipient: '', result: '')] }
  let(:report) {
    mock_model Incidents::Incident, incident_number: "12-345", area: double(name: 'County'), narrative: 'Test 123', created_at: Time.zone.now,
                                    address: '123', city: '123', state: '123', zip: '123', county: 'County', chapter: chapter
  }

  let(:chapter) { FactoryGirl.build_stubbed :chapter }
  subject { Incidents::Notifications::Mailer }
  before(:each) { Bitly.stub(client: double(:shorten => double(short_url: "https://short.url"))) }

  describe "no_incident_report" do
    let(:event) { mock_model Incidents::Notifications::Event, event_type: 'event', event: 'incident_missing_report'}
    let(:mail) { subject.notify_event(person, false, event, report, 'notification') }

    before(:each) { report.stub dispatch_log: double( delivered_to: "Bob", log_items: log_items) }

    it "renders the headers" do
      mail.subject.should eq("Missing Incident Report For County")
      mail.from.should eq(from_address)
    end

    it "should be to the county designated contact" do
      mail.to.should eq([person.email])
    end

    it "renders the body" do
      mail.body.encoded.should match("An incident number was created")
      mail.body.encoded.should match("Person Contacted by Dispatch: Bob")
    end
  end

  describe "new_incident" do
    let(:event) { mock_model Incidents::Notifications::Event, event_type: 'event', event: 'new_incident'}
    let(:dispatch) { double :dispatch_log, incident_type: 'Flood', address: Faker::Address.street_address, displaced: 3, 
      services_requested: "Help!", agency: "Fire Department", contact_name: "Name", contact_phone: "Phone", 
      delivered_at: nil, log_items: log_items
    }
    let(:mail) { subject.notify_event(person, false, event, report, 'notification') }

    before(:each) { report.stub dispatch_log: dispatch }

    it "renders the headers" do
      mail.subject.should eq("New Incident For County")
      mail.from.should eq(from_address)
    end

    it "should be to the recipient" do
      mail.to.should eq([person.email])
    end

    it "renders the body" do
      mail.body.encoded.should match("Incident Type: Flood")
      mail.body.encoded.should_not match("Delivered At")
    end
  end

  describe "incident_dispatched" do
    let(:event) { mock_model Incidents::Notifications::Event, event_type: 'event', event: 'incident_dispatched'}
    let(:dispatch) { double :dispatch_log, incident_type: 'Flood', address: Faker::Address.street_address, displaced: 3, 
      services_requested: "Help!", agency: "Fire Department", contact_name: "Name", contact_phone: "Phone", 
      delivered_at: Time.zone.now, delivered_to: "Bob", log_items: log_items
    }
    let(:mail) { subject.notify_event(person, false, event, report, 'notification') }
    before(:each) { report.stub dispatch_log: dispatch }

    it "renders the headers" do
      mail.subject.should eq("Incident For County Dispatched")
      mail.from.should eq(from_address)
    end

    it "should be to the recipient" do
      mail.to.should eq([person.email])
    end

    it "renders the body" do
      mail.body.encoded.should match("Incident Type: Flood")
      mail.body.encoded.should match("Delivered To: Bob")
    end
  end

  describe "incident_report_filed" do
    let(:event) { mock_model Incidents::Notifications::Event, event_type: 'event', event: 'incident_report_filed'}
    let(:dat) { FactoryGirl.build_stubbed :dat_incident}
    let(:report) { FactoryGirl.build_stubbed :incident, dat_incident: dat}
    let(:mail) { subject.notify_event(person, false, event, report, 'notification', is_new: true) }

    it "renders the headers" do
      mail.subject.should eq("Incident Report Filed For #{report.county}")
      mail.from.should eq(from_address)
    end

    it "should be to the designated contact" do
      mail.to.should eq([person.email])
    end

    it "renders the body" do
      mail.body.encoded.should match("A New DAT Incident Report was filed")
    end
  end

  describe "incident_invalid" do
    let(:event) { mock_model Incidents::Notifications::Event, event_type: 'event', event: 'incident_invalid'}
    let(:report) { FactoryGirl.build_stubbed :incident, incident_type: 'duplicate'}
    let(:mail) { subject.notify_event(person, false, event, report, 'notification') }

    it "renders the headers" do
      mail.subject.should eq("Incident #{report.incident_number} Marked Invalid")
      mail.from.should eq(from_address)
    end

    it "should be to the designated contact" do
      mail.to.should eq([person.email])
    end

    it "renders the body" do
      mail.body.encoded.should match("The incident below was marked as invalid.")
    end
  end

  describe "escalation" do
    let(:use_sms) { false }
    let(:template) { 'notification' }
    let(:event) { mock_model Incidents::Notifications::Event, event_type: 'escalation', event: 'escalation'}
    let(:mail) { subject.notify_event(person, use_sms, event, report, template) }
    let(:report) { FactoryGirl.build_stubbed :incident }

    it "renders the headers" do
      mail.subject.should eq("Notification for #{report.incident_number}")
      mail.from.should eq(from_address)
    end

    it "should be to the recipient" do
      mail.to.should eq([person.email])
    end

    it "renders the body" do
      mail.body.encoded.should match("Incident Type: Fire")
    end

    describe "as sms" do
      let(:use_sms) { true }
      let(:from_address) { 'sms@dcsops.org' }
      before(:each) { person.stub(sms_addresses: ['test@vtext.com']) }

      it "renders" do
        mail.to.should eq([person.sms_addresses.first])
        mail.from.should eq([from_address])
      end
    end
  end
end
