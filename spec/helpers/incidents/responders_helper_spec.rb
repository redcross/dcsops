require 'spec_helper'

describe Incidents::RespondersHelper, :type => :helper do

  let!(:incident) { double(:incident, id: 1234, responder_assignments: [], region: double(:region, to_param: "123", incidents_enable_messaging: true)) }
  let!(:person) { FactoryGirl.build_stubbed :person, city: "MyCity" }
  let!(:assignment) { mock_model(Scheduler::ShiftAssignment, person: person, shift: double(:shift, name: 'Test Shift')) }

  before do
    helper.stub parent: incident
    helper.stub recruitments: []
    inc = self.incident
    helper.class_eval <<-RUBY, __FILE__, __LINE__+1
      def new_resource_path *args
        new_incidents_region_incident_responder_path('region', 'incident', *args)
      end
      def edit_resource_path *args
        edit_incidents_region_incident_responder_path('region', 'incident', *args)
      end
    RUBY

  end

  describe "#person_json" do
    it "should return json" do
      obj = JSON.parse helper.person_json(person)
      expect(obj).to be_a(Hash)
      expect(obj.keys).to match_array(%w(lat lng id full_name city edit_url assigned))
    end

    it "should return json with role when given an assignment" do
      obj = JSON.parse helper.person_json(person, assignment)
      expect(obj).to be_a(Hash)
      expect(obj.keys).to match_array(%w(lat lng id full_name city role edit_url assigned))
      expect(obj['role']).to eq(assignment.shift.name)
    end
  end

  # This really tests the helpers that are called from the _person_row partial
  describe "#person_schedule_row" do
    it "should return html" do
      res = helper.links(person, assignment, true)
      expect(res).to be_a(ActiveSupport::SafeBuffer)
    end

    it "should link to a new assignment" do
      res = helper.links(person, assignment, true)
      expect(res).to match(%r[responders/new\?person_id=#{person.id}])
    end

    it "should link to an existing assignment" do
      assignment = FactoryGirl.create :responder_assignment, person: person
      res = helper.links(person, assignment, true)
      expect(res).to match(%r[responders/#{assignment.id}/edit])
      expect(role_name(assignment)).to match(assignment.humanized_role)
    end

    it "should provide the shift assignment name" do
      assignment = FactoryGirl.build_stubbed :shift_assignment, person: person
      res = helper.role_name(assignment)
      expect(res).to match(assignment.shift.name)
    end

    it "should not link if not editable" do
      res = helper.links(person, assignment, false)
      expect(res).not_to match(%r[responders/new\?person_id=#{person.id}])
    end

    it "should show message sent if a recruitment exists" do
      helper.stub recruitments: {person.id => [double(:recruitment, available?: false, unavailable?: false)]}
      res = helper.recruit_action(person, true)
      expect(res).to match("Message Sent")
    end

    it "should show available if a recruitment exists" do
      helper.stub recruitments: {person.id => [double(:recruitment, available?: true, unavailable?: false)]}
      res = helper.recruit_action(person, true)
      expect(res).to match("Available")
    end

    it "should show unavailable if a recruitment exists" do
      helper.stub recruitments: {person.id => [double(:recruitment, available?: false, unavailable?: true)]}
      res = helper.recruit_action(person, true)
      expect(res).to match("Not Available")
    end
  end

end