require 'spec_helper'

describe Incidents::DispatchImporter do
  subject { Incidents::DispatchImporter.new }
  let(:region) { FactoryGirl.create :region }
  let(:fixture_name) { self.class.description }
  let(:fixture_path) { "spec/fixtures/incidents/dispatch_logs/#{fixture_name}" }
  let(:fixture) { File.read fixture_path }

  let(:import) do
    subject.import_data region, fixture
  end

  let(:geocode_result) {double(:geocode_result, success?: true, lat: 0, lng: 0, city: Faker::Address.city, state: Faker::Address.state, district: Faker::Address.city, zip: Faker::Address.zip_code)}
  let(:response_territory) { FactoryGirl.create :response_territory, region: region }

  before do
    allow(Incidents::DispatchImporter.geocoder).to receive(:geocode).and_return(geocode_result)
    allow(Incidents::Notifications::Notification).to receive :create_for_event
    allow_any_instance_of(Incidents::ResponseTerritoryMatcher).to receive(:match_response_territory).and_return(response_territory)
  end

  describe "1.txt" do
    let!(:shift_territory) {FactoryGirl.create :shift_territory, region: region, name: 'Contra Costa'}
    it "should parse the incident" do
      import

      inc = Incidents::DispatchLog.first
      expect(inc).not_to be_nil

      expect(inc.incident_number).to eq("14-044")
      expect(inc.incident_type).to eq("Flooding")
      expect(inc.address).to eq('311 Dogwood Lane, BRENTWOOD')
      expect(inc.county).to eq('Contra Costa')
      expect(inc.displaced).to eq("374")
      expect(inc.services_requested).to eq("We need food and possibly an evacuation center. Sentence on line two.")
      expect(inc.agency).to eq("The Brentwood Police Dept")
      expect(inc.contact_name).to eq("Sally Smith")
      expect(inc.contact_phone).to eq("(510)227-9475")
      expect(inc.caller_id).to eq("5105954566")
      expect(inc.state).to eq("CA")
      expect(inc.message_number).to eq("21251520000044")

      expect(inc.received_at).to eq(region.time_zone.parse( "2013-06-13 19:16:00"))
      expect(inc.delivered_at).to eq(region.time_zone.parse( "2013-06-13 19:18:00"))
      
      expect(inc.delivered_to).to eq('JOHN')
    end

    it "should parse the event logs" do
      import

      inc = Incidents::DispatchLog.first
      expect(inc).not_to be_nil

      expect(inc.log_items.size).to eq(9)

      dial = inc.log_items.detect{|li| li.action_type == 'Dial'}

      expect(dial).not_to be_nil
      expect(dial.result).to eq("RLY'D")
      expect(dial.recipient).to eq("650-555-1212 DOE, JOHN - CELL")
      expect(dial.action_at).to eq(region.time_zone.parse( "2013-06-13 19:17:00"))
      expect(dial.operator).to eq('FBGL')
    end

    it "should create an incident" do
      import

      inc = Incidents::Incident.first
      expect(inc).not_to be_nil

      expect(inc.incident_number).to eq('14-044')
      expect(inc.date).to eq(Date.civil(2013, 6, 13))
      expect(inc.shift_territory).to eq(shift_territory)
      expect(inc.region).to eq(region)
      expect(inc.status).to eq('open')
      expect(inc.state).to eq('CA')
    end

    it "should create several event logs" do
      import

      log = Incidents::DispatchLog.first
      inc = Incidents::Incident.first
      
      received = inc.event_logs.detect{|e| e.event == 'dispatch_received'}
      expect(received).not_to be_nil
      expect(received.event_time).to eq(log.received_at)

      delivered = inc.event_logs.detect{|e| e.event == 'dispatch_relayed'}
      expect(delivered).not_to be_nil
      expect(delivered.event_time).to eq(log.delivered_at)

      expect(inc.event_logs.size).to eq(5)
    end

    it "should notify IncidentCreated" do
      expect(Incidents::Notifications::Notification).to receive(:create_for_event).with(anything, 'new_incident')

      import
    end

    it "should not notify DispatchLogUpdated" do
      expect(Incidents::Notifications::Notification).not_to receive(:create_for_event).with(anything, 'incident_dispatched')

      import
    end

    describe "with an incident already existing" do
      before(:each) do
        @inc = FactoryGirl.create :incident, incident_number: '14-044', region: region
      end
      let(:fixture_name) { self.class.superclass.description }

      it "should assign the existing incident" do
        import

        log = Incidents::DispatchLog.first
        expect(log.incident).to eq(@inc)
      end

      it "should not notify IncidentCreated" do
        expect(Incidents::Notifications::Notification).not_to receive(:create_for_event).with(anything, 'new_incident')

        import
      end

      it "should notify DispatchLogUpdated" do
        expect(Incidents::Notifications::Notification).to receive(:create_for_event).with(anything, 'incident_dispatched')

        import
      end
    end
  end

  describe "2.txt" do
    let!(:shift_territory) {FactoryGirl.create :shift_territory, region: region, name: 'San Francisco'}
    it "should parse the incident" do
      import

      inc = Incidents::DispatchLog.first
      expect(inc).not_to be_nil

      expect(inc.incident_number).to eq("14-043")
      expect(inc.incident_type).to eq("Apartment Fire")
      expect(inc.address).to eq('211 Main St, SAN FRANCISCO')
      expect(inc.county).to eq('San Francisco')
      expect(inc.displaced).to eq("36")
      expect(inc.services_requested).to eq("Canteine for the fire dept and the 36 people that live he also housing for the tenants.")
      expect(inc.agency).to eq("San Francisco Fire Dept")
      expect(inc.contact_name).to eq("Bob Boberson")
      expect(inc.contact_phone).to eq("(415)555-1212")
      expect(inc.caller_id).to eq("5105551212")

      expect(inc.received_at).to eq(region.time_zone.parse( "2013-06-13 18:57:00"))
      expect(inc.delivered_at).to eq(region.time_zone.parse( "2013-06-13 19:07:00"))
      
      expect(inc.delivered_to).to eq('MR. DOE')
    end

    it "should parse the event logs" do
      import

      inc = Incidents::DispatchLog.first
      expect(inc).not_to be_nil

      expect(inc.log_items.size).to eq(13)

      dial = inc.log_items.order(action_at: :desc).detect{|li| li.action_type == 'Dial'}
      expect(dial).not_to be_nil
      expect(dial.result).to eq("RELAYED")
      expect(dial.recipient).to eq("650-555-1212 DOE, JOHN - CELL")
      expect(dial.action_at).to eq(region.time_zone.parse( "2013-06-13 19:05:00"))
      expect(dial.operator).to eq('PMED')
    end

    it "should create an incident" do
      import

      inc = Incidents::Incident.first
      expect(inc).not_to be_nil

      expect(inc.incident_number).to eq('14-043')
      expect(inc.date).to eq(Date.civil(2013, 6, 13))
      expect(inc.shift_territory).to eq(shift_territory)
      expect(inc.region).to eq(region)
    end

    it "should create several event logs" do
      import

      log = Incidents::DispatchLog.first
      inc = Incidents::Incident.first
      
      received = inc.event_logs.detect{|e| e.event == 'dispatch_received'}
      expect(received).not_to be_nil
      expect(received.event_time).to eq(log.received_at)

      delivered = inc.event_logs.detect{|e| e.event == 'dispatch_relayed'}
      expect(delivered).not_to be_nil
      expect(delivered.event_time).to eq(log.delivered_at)

      expect(inc.event_logs.size).to eq(9)
    end
  end

  describe "4.txt" do
    let!(:shift_territory) {FactoryGirl.create :shift_territory, region: region, name: 'San Francisco'}
    let(:incident_details) {
      {incident_number: '14-004',
            incident_type: 'Structure Fire',
            address: '123 Main St Street, SAN FRANCISCO',
            cross_street: 'Mission & Howard',
            county: 'San Francisco',
            displaced: "4",
            services_requested: 'Everything - shelter, food and clothing (red cross case , reference number for fire dept is )',
            agency: 'The American Red Cross',
            contact_name: 'SF Fire Department',
            contact_phone: '(415)5551212',
            caller_id: '8005551212',
            received_at: nil,
            delivered_at: region.time_zone.parse( "2013-07-05 00:25:00")}
    }
    let(:num_event_logs) {10}
    let(:incident_attributes) {
      {incident_number: '14-004', date: region.time_zone.today, shift_territory: shift_territory, region: region}
    }
    it "should parse the incident" do
      import

      inc = Incidents::DispatchLog.first
      expect(inc).not_to be_nil

      incident_details.each do |attr, val|
        expect(inc.send(attr)).to eq(val.presence)
      end

    end

    it "should parse the event logs" do
      import

      inc = Incidents::DispatchLog.first
      expect(inc).not_to be_nil

      expect(inc.log_items.size).to eq(num_event_logs)
    end

    it "should create an incident" do
      import

      inc = Incidents::Incident.first
      expect(inc).not_to be_nil

      incident_attributes.each do |attr, val|
        expect(inc.send(attr)).to eq(val.presence)
      end
    end
  end

  describe "5.txt" do
    let!(:shift_territory) {FactoryGirl.create :shift_territory, region: region, name: 'San Francisco'}
    let(:incident_details) {
      {incident_number: '15-047',
            incident_type: "",
            address: ', SPRINGFIELD',
            delivered_at: region.time_zone.parse( "2014-07-18 12:44:00")}
    }
    it "should parse the incident" do
      import

      inc = Incidents::DispatchLog.first
      expect(inc).not_to be_nil
      expect(inc.incident).not_to be_nil

      incident_details.each do |attr, val|
        expect(inc.send(attr)).to eq(val)
      end

    end
  end

  describe "6.txt" do
    let!(:shift_territory) {FactoryGirl.create :shift_territory, region: region, name: 'San Francisco'}
    let(:incident_details) {
      {incident_number: nil,
            incident_type: 'Structure Fire',
            address: '123 Main St Street, SAN FRANCISCO',
            delivered_at: region.time_zone.parse( "2013-07-05 00:25:00")}
    }
    it "should parse the incident" do
      import

      inc = Incidents::DispatchLog.first
      expect(inc).not_to be_nil
      expect(inc.incident).to be_nil
      expect(inc.incident_number).to be_nil

      incident_details.each do |attr, val|
        expect(inc.send(attr)).to eq(val)
      end

    end
  end
end