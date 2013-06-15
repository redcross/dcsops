require 'spec_helper'

describe Incidents::DispatchImporter do
  subject { Incidents::DispatchImporter.new }
  let(:chapter) { FactoryGirl.create :chapter }
  let(:fixture_name) { self.class.description }
  let(:fixture_path) { "spec/fixtures/incidents/dispatch_logs/#{fixture_name}" }
  let(:fixture) { File.read fixture_path }

  before(:each) do
    subject.import_data chapter, fixture
  end

  describe "1.txt" do
    it "should parse the incident" do
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
      inc.delivered_at.should == chapter.time_zone.parse( "2013-06-13 19:18:20")
      
      inc.delivered_to.should == 'JOHN'
    end

    it "should parse the event logs" do
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
  end
end