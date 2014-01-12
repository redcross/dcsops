require 'spec_helper'

describe Incidents::RespondersHelper do

  let!(:incident) { double(:incident, id: 1234, responder_assignments: []) }
  let!(:person) { FactoryGirl.build_stubbed :person, city: "MyCity" }
  let!(:assignment) { double(:assignment, person: person, shift: double(:shift, name: 'Test Shift')) }

  before do
    helper.stub parent: incident
    inc = self.incident
    helper.class_eval do
      define_method :new_resource_path do|*args|
        args.insert 0, inc.id
        new_incidents_incident_responder_path(*args)
      end
      define_method :edit_resource_path do|*args|
        args.insert 0, inc.id
        edit_incidents_incident_responder_path(*args)
      end
    end

  end

  describe "#person_json" do
    it "should return json" do
      obj = JSON.parse helper.person_json(person)
      obj.should be_a(Hash)
      obj.keys.should =~ %w(lat lng id full_name city)
    end

    it "should return json with role when given an assignment" do
      obj = JSON.parse helper.person_json(person, assignment)
      obj.should be_a(Hash)
      obj.keys.should =~ %w(lat lng id full_name city role)
      obj['role'].should == assignment.shift.name
    end
  end

  describe "#person_row" do
    it "should return html" do
      res = helper.person_row(assignment, true)
      res.should be_a(ActiveSupport::SafeBuffer)
    end

    it "should link to a new assignment" do
      res = helper.person_row(assignment, true)
      res.should match(%r[responders/new\?person_id=#{person.id}])
    end

    it "should link to an existing assignment" do
      assignment = FactoryGirl.create :responder_assignment, person: person
      res = helper.person_row(assignment, true)
      res.should match(%r[responders/#{assignment.id}/edit])
      res.should match(assignment.humanized_role)
    end

    it "should provide the shift assignment name" do
      assignment = FactoryGirl.create :shift_assignment, person: person
      res = helper.person_row(assignment, true)
      res.should match(assignment.shift.name)
    end

    it "should not link if not editable" do
      res = helper.person_row(assignment, false)
      res.should_not match(%r[responders/new\?person_id=#{person.id}])
    end
  end

end