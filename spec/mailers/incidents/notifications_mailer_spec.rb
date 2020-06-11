require "spec_helper"

describe Incidents::Notifications::Mailer, :type => :mailer do
  let(:from_address) {["incidents@dcsops.org"]}
  let(:person) { FactoryGirl.build_stubbed :person }
  let(:log_items) { [double(:dispatch_log_item, action_at: Time.zone.now, action_type: 'Dial', recipient: '', result: '')] }
  let(:report) {
    mock_model Incidents::Incident, incident_number: "12-345", area: double(name: 'County'), narrative: 'Test 123', created_at: Time.zone.now,
                                    address: '123', city: '123', state: '123', zip: '123', county: 'County', region: region, humanized_incident_type: 'Test'
  }

  let(:region) { FactoryGirl.build_stubbed :region }
  subject { Incidents::Notifications::Mailer }
  before(:each) { Bitly.stub(client: double(:shorten => double(short_url: "https://short.url"))) }

  describe "no_incident_report" do
    let(:event) { mock_model Incidents::Notifications::Event, event_type: 'event', event: 'incident_missing_report'}
    let(:mail) { subject.notify_event(person, false, event, report, 'notification') }

    before(:each) { report.stub dispatch_log: double( delivered_to: "Bob", log_items: log_items) }

    it "renders the headers" do
      expect(mail.subject).to eq("Missing Incident Report For County")
      expect(mail.from).to eq(from_address)
    end

    it "should be to the county designated contact" do
      expect(mail.to).to eq([person.email])
    end

    it "renders the body" do
      expect(mail.body.encoded).to match("An incident number was created")
      expect(mail.body.encoded).to match("Person Contacted by Dispatch: Bob")
    end
  end

  describe "new_incident" do
    let(:use_sms) { false }
    let(:event) { mock_model Incidents::Notifications::Event, event_type: 'event', event: 'new_incident'}
    let(:dispatch) { double :dispatch_log, incident_type: 'Flood', address: Faker::Address.street_address, displaced: 3, 
      services_requested: "Help!", agency: "Fire Department", contact_name: "Name", contact_phone: "Phone", 
      delivered_at: nil, log_items: log_items
    }
    let(:mail) { subject.notify_event(person, use_sms, event, report, 'notification') }

    before(:each) { report.stub dispatch_log: dispatch }

    it "renders the headers" do
      expect(mail.subject).to eq("New Incident For County")
      expect(mail.from).to eq(from_address)
    end

    it "should be to the recipient" do
      expect(mail.to).to eq([person.email])
    end

    it "renders the body" do
      expect(mail.body.encoded).to match("Incident Type: Flood")
      expect(mail.body.encoded).not_to match("Delivered At")
    end

    describe "as sms" do
      let(:use_sms) { true }
      let(:from_address) { 'sms@dcsops.org' }
      before(:each) { person.stub(sms_addresses: ['test@vtext.com']) }

      it "renders" do
        expect(mail.message.to).to eq([person.sms_addresses.first])
        expect(mail.message.from).to eq([from_address])
      end
    end
  end

  describe "incident_dispatched" do
    let(:use_sms) { false }
    let(:event) { mock_model Incidents::Notifications::Event, event_type: 'event', event: 'incident_dispatched'}
    let(:dispatch) { double :dispatch_log, incident_type: 'Flood', address: Faker::Address.street_address, displaced: 3, 
      services_requested: "Help!", agency: "Fire Department", contact_name: "Name", contact_phone: "Phone", 
      delivered_at: Time.zone.now, delivered_to: "Bob", log_items: log_items
    }
    let(:mail) { subject.notify_event(person, use_sms, event, report, 'notification') }
    before(:each) { report.stub dispatch_log: dispatch }

    it "renders the headers" do
      expect(mail.subject).to eq("Incident For County Dispatched")
      expect(mail.from).to eq(from_address)
    end

    it "should be to the recipient" do
      expect(mail.to).to eq([person.email])
    end

    it "renders the body" do
      expect(mail.body.encoded).to match("Incident Type: Flood")
      expect(mail.body.encoded).to match("Delivered To: Bob")
    end

    describe "as sms" do
      let(:use_sms) { true }
      let(:from_address) { 'sms@dcsops.org' }
      before(:each) { person.stub(sms_addresses: ['test@vtext.com']) }

      it "renders" do
        expect(mail.message.to).to eq([person.sms_addresses.first])
        expect(mail.message.from).to eq([from_address])
      end
    end
  end

  describe "incident_report_filed" do
    let(:use_sms) { false }
    let(:event) { mock_model Incidents::Notifications::Event, event_type: 'event', event: 'incident_report_filed'}
    let(:dat) { FactoryGirl.build_stubbed :dat_incident}
    let(:report) { FactoryGirl.build_stubbed :incident, dat_incident: dat}
    let(:mail) { subject.notify_event(person, use_sms, event, report, 'notification', is_new: true) }

    it "renders the headers" do
      expect(mail.subject).to eq("Incident Report Filed For #{report.county}")
      expect(mail.from).to eq(from_address)
    end

    it "should be to the designated contact" do
      expect(mail.to).to eq([person.email])
    end

    it "renders the body" do
      expect(mail.body.encoded).to match("A New DAT Incident Report was filed")
    end

    describe "as sms" do
      let(:use_sms) { true }
      let(:from_address) { 'sms@dcsops.org' }
      before(:each) { person.stub(sms_addresses: ['test@vtext.com']) }

      it "renders" do
        expect(mail.message.to).to eq([person.sms_addresses.first])
        expect(mail.message.from).to eq([from_address])
      end
    end
  end

  describe "incident_invalid" do
    let(:use_sms) { false }
    let(:event) { mock_model Incidents::Notifications::Event, event_type: 'event', event: 'incident_invalid'}
    let(:report) { FactoryGirl.build_stubbed :incident, incident_type: 'duplicate'}
    let(:mail) { subject.notify_event(person, use_sms, event, report, 'notification') }

    it "renders the headers" do
      expect(mail.subject).to eq("Incident #{report.incident_number} Marked Invalid")
      expect(mail.from).to eq(from_address)
    end

    it "should be to the designated contact" do
      expect(mail.to).to eq([person.email])
    end

    it "renders the body" do
      expect(mail.body.encoded).to match("The incident below was marked as invalid.")
    end

    describe "as sms" do
      let(:use_sms) { true }
      let(:from_address) { 'sms@dcsops.org' }
      before(:each) { person.stub(sms_addresses: ['test@vtext.com']) }

      it "renders" do
        expect(mail.message.to).to eq([person.sms_addresses.first])
        expect(mail.message.from).to eq([from_address])
      end
    end
  end

  describe "escalation" do
    let(:use_sms) { false }
    let(:template) { 'notification' }
    let(:event) { mock_model Incidents::Notifications::Event, event_type: 'escalation', event: 'escalation'}
    let(:mail) { subject.notify_event(person, use_sms, event, report, template) }
    let(:report) { FactoryGirl.build_stubbed :incident }

    it "renders the headers" do
      expect(mail.subject).to eq("Notification for #{report.incident_number}")
      expect(mail.from).to eq(from_address)
    end

    it "should be to the recipient" do
      expect(mail.to).to eq([person.email])
    end

    it "renders the body" do
      expect(mail.body.encoded).to match("Incident Type: Fire")
    end

    describe "as sms" do
      let(:use_sms) { true }
      let(:from_address) { 'sms@dcsops.org' }
      before(:each) { person.stub(sms_addresses: ['test@vtext.com']) }

      it "renders" do
        expect(mail.message.to).to eq([person.sms_addresses.first])
        expect(mail.message.from).to eq([from_address])
      end
    end
  end
end
