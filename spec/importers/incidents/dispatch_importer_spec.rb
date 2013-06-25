require 'spec_helper'

describe Incidents::DispatchImporter do
  subject { Incidents::DispatchImporter.new }
  let(:chapter) { FactoryGirl.create :chapter }
  let(:fixture_name) { self.class.description }
  let(:fixture_path) { "spec/fixtures/incidents/dispatch_logs/#{fixture_name}" }
  let(:fixture) { File.read fixture_path }

  let(:import) do
    county # load it so it gets created
    subject.import_data chapter, fixture
  end

  describe "1.txt" do
    let(:county) {FactoryGirl.create :county, chapter: chapter, name: 'Contra Costa'}
    it "should parse the incident" do
      import

      inc = Incidents::DispatchLog.first
      inc.should_not be_nil

      inc.incident_number.should == "14-044"
      inc.incident_type.should == "Flooding"
      inc.address.should == '311 Dogwood Lane, BRENTWOOD'
      inc.county_name.should == 'Contra Costa'
      inc.displaced.should == "374"
      inc.services_requested.should == "We need food and possibly an evacuation center. Sentence on line two."
      inc.agency.should == "The Brentwood Police Dept"
      inc.contact_name.should == "Sally Smith"
      inc.contact_phone.should == "(510)227-9475"
      inc.caller_id.should == "5105954566"

      inc.received_at.should == chapter.time_zone.parse( "2013-06-13 19:16:00")
      inc.delivered_at.should == chapter.time_zone.parse( "2013-06-13 19:18:00")
      
      inc.delivered_to.should == 'JOHN'
    end

    it "should parse the event logs" do
      import

      inc = Incidents::DispatchLog.first
      inc.should_not be_nil

      inc.log_items.should have(9).items

      dial = inc.log_items.detect{|li| li.action_type == 'Dial'}

      dial.should_not be_nil
      dial.result.should == "RLY'D"
      dial.recipient.should == "650-555-1212 DOE, JOHN - CELL"
      dial.action_at.should == chapter.time_zone.parse( "2013-06-13 19:17:00")
      dial.operator.should == 'FBGL'
    end

    it "should create an incident" do
      import

      inc = Incidents::Incident.first
      inc.should_not be_nil

      inc.incident_number.should == '14-044'
      inc.date.should == Date.civil(2013, 6, 13)
      inc.county.should == county
      inc.chapter.should == chapter
    end

    it "should create several event logs" do
      import

      log = Incidents::DispatchLog.first
      inc = Incidents::Incident.first
      
      received = inc.event_logs.detect{|e| e.event == 'dispatch_received'}
      received.should_not be_nil
      received.event_time.should == log.received_at

      delivered = inc.event_logs.detect{|e| e.event == 'dispatch_relayed'}
      delivered.should_not be_nil
      delivered.event_time.should == log.delivered_at

      inc.event_logs.should have(5).items
    end

    it "should notify IncidentCreated" do
      Incidents::IncidentCreated.any_instance.should_receive(:save)

      import
    end

    it "should not notify DispatchLogUpdated" do
      Incidents::DispatchLogUpdated.any_instance.should_not_receive(:save)

      import
    end

    describe "with an incident already existing" do
      before(:each) do
        @inc = FactoryGirl.create :incident, incident_number: '14-044', chapter: chapter
      end
      let(:fixture_name) { self.class.superclass.description }

      it "should assign the existing incident" do
        import

        log = Incidents::DispatchLog.first
        log.incident.should == @inc
      end

      it "should not notify IncidentCreated" do
        Incidents::IncidentCreated.any_instance.should_not_receive(:save)

        import
      end

      it "should notify DispatchLogUpdated" do
        Incidents::DispatchLogUpdated.any_instance.should_receive(:save)

        import
      end
    end
  end

  describe "2.txt" do
    let(:county) {FactoryGirl.create :county, chapter: chapter, name: 'San Francisco'}
    it "should parse the incident" do
      import

      inc = Incidents::DispatchLog.first
      inc.should_not be_nil

      inc.incident_number.should == "14-043"
      inc.incident_type.should == "Apartment Fire"
      inc.address.should == '211 Main St, SAN FRANCISCO'
      inc.county_name.should == 'San Francisco'
      inc.displaced.should == "36"
      inc.services_requested.should == "Canteine for the fire dept and the 36 people that live he also housing for the tenants."
      inc.agency.should == "San Francisco Fire Dept"
      inc.contact_name.should == "Bob Boberson"
      inc.contact_phone.should == "(415)555-1212"
      inc.caller_id.should == "5105551212"

      inc.received_at.should == chapter.time_zone.parse( "2013-06-13 18:57:00")
      inc.delivered_at.should == chapter.time_zone.parse( "2013-06-13 19:07:00")
      
      inc.delivered_to.should == 'MR. DOE'
    end

    it "should parse the event logs" do
      import

      inc = Incidents::DispatchLog.first
      inc.should_not be_nil

      inc.log_items.should have(13).items

      dial = inc.log_items.detect{|li| li.action_type == 'Dial'}
      dial.should_not be_nil
      dial.result.should == "RELAYED"
      dial.recipient.should == "650-555-1212 DOE, JOHN - CELL"
      dial.action_at.should == chapter.time_zone.parse( "2013-06-13 19:05:00")
      dial.operator.should == 'PMED'
    end

    it "should create an incident" do
      import

      inc = Incidents::Incident.first
      inc.should_not be_nil

      inc.incident_number.should == '14-043'
      inc.date.should == Date.civil(2013, 6, 13)
      inc.county.should == county
      inc.chapter.should == chapter
    end

    it "should create several event logs" do
      import

      log = Incidents::DispatchLog.first
      inc = Incidents::Incident.first
      
      received = inc.event_logs.detect{|e| e.event == 'dispatch_received'}
      received.should_not be_nil
      received.event_time.should == log.received_at

      delivered = inc.event_logs.detect{|e| e.event == 'dispatch_relayed'}
      delivered.should_not be_nil
      delivered.event_time.should == log.delivered_at

      inc.event_logs.should have(9).items
    end
  end
end