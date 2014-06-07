require 'spec_helper'

describe Incidents::RespondersHelper do

  let!(:incident) { double(:incident, id: 1234, responder_assignments: [], chapter: double(:chapter, to_param: "123", incidents_enable_messaging: true)) }
  let!(:person) { FactoryGirl.build_stubbed :person, city: "MyCity" }
  let!(:assignment) { mock_model(Scheduler::ShiftAssignment, person: person, shift: double(:shift, name: 'Test Shift')) }

  before do
    helper.stub parent: incident
    helper.stub recruitments: []
    inc = self.incident
    helper.class_eval <<-RUBY, __FILE__, __LINE__+1
      def new_resource_path *args
        new_incidents_chapter_incident_responder_path('chapter', 'incident', *args)
      end
      def edit_resource_path *args
        edit_incidents_chapter_incident_responder_path('chapter', 'incident', *args)
      end
    RUBY

  end

  describe "#person_json" do
    it "should return json" do
      obj = JSON.parse helper.person_json(person)
      obj.should be_a(Hash)
      obj.keys.should =~ %w(lat lng id full_name city edit_url assigned)
    end

    it "should return json with role when given an assignment" do
      obj = JSON.parse helper.person_json(person, assignment)
      obj.should be_a(Hash)
      obj.keys.should =~ %w(lat lng id full_name city role edit_url assigned)
      obj['role'].should == assignment.shift.name
    end
  end

  describe "#person_schedule_row" do
    it "should return html" do
      res = helper.person_schedule_row(assignment, true)
      res.should be_a(ActiveSupport::SafeBuffer)
    end

    it "should link to a new assignment" do
      res = helper.person_schedule_row(assignment, true)
      res.should match(%r[responders/new\?person_id=#{person.id}])
    end

    it "should link to an existing assignment" do
      assignment = FactoryGirl.create :responder_assignment, person: person
      res = helper.person_schedule_row(assignment, true)
      res.should match(%r[responders/#{assignment.id}/edit])
      res.should match(assignment.humanized_role)
    end

    it "should provide the shift assignment name" do
      assignment = FactoryGirl.build_stubbed :shift_assignment, person: person
      res = helper.person_schedule_row(assignment, true)
      res.should match(assignment.shift.name)
    end

    it "should not link if not editable" do
      res = helper.person_schedule_row(assignment, false)
      res.should_not match(%r[responders/new\?person_id=#{person.id}])
    end

    it "should show message sent if a recruitment exists" do
      helper.stub recruitments: {person.id => [double(:recruitment, available?: false, unavailable?: false)]}
      res = helper.person_schedule_row(assignment, true)
      res.should match("Message Sent")
    end

    it "should show available if a recruitment exists" do
      helper.stub recruitments: {person.id => [double(:recruitment, available?: true, unavailable?: false)]}
      res = helper.person_schedule_row(assignment, true)
      res.should match("Available")
    end

    it "should show unavailable if a recruitment exists" do
      helper.stub recruitments: {person.id => [double(:recruitment, available?: false, unavailable?: true)]}
      res = helper.person_schedule_row(assignment, true)
      res.should match("Not Available")
    end
  end

end