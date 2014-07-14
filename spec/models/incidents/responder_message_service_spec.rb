require 'spec_helper'

describe Incidents::ResponderMessageService, :type => :model do
  let(:chapter) { FactoryGirl.build_stubbed :chapter}
  let(:incident) { FactoryGirl.build_stubbed :incident, chapter: chapter }
  let(:assignment) { FactoryGirl.build_stubbed :responder_assignment, incident: incident }
  let(:incoming_message) { FactoryGirl.build_stubbed :incoming_responder_message, message: "commands" }
  subject { Incidents::ResponderMessageService.new(incoming_message) }
  before(:each) {
    subject.stub assignment: assignment
    allow(subject).to receive :short_url do |arg|
      arg
    end
    incoming_message.stub save: true
  }

  describe '#reply' do
    it "checks that person is assigned to an open incident" do
      subject.stub open_assignment_for_person: nil
      response = subject.reply
      expect(response.message).to include("not currently assigned")
    end

    it "calls handle_command" do
      subject.stub open_assignment_for_person: assignment
      allow(incoming_message).to receive :save
      response = subject.reply
      expect(response.message).not_to be_blank
    end
  end

  describe '#open_assignment_for_person' do
    it "returns an assignment" do
      ra = FactoryGirl.create :responder_assignment
      expect(subject.open_assignment_for_person(ra.person)).to eq(ra)
    end
  end

  describe '#handle_command for assignment matchers' do
    let(:outgoing_message) { Incidents::ResponderMessage.new }
    let(:matchers) { Incidents::ResponderMessageService::ASSIGNMENT_MATCHERS }
    before(:each) {
      subject.stub response: outgoing_message
    }

    it "dispatches incident info" do
      subject.handle_command "incident", matchers
      expect(outgoing_message.message).to include(incident.incident_number)
    end
    describe "dispatches on scene" do
      it "marks the assignment" do
        expect(assignment).to receive :on_scene!
        subject.handle_command "arrived", matchers
        expect(outgoing_message.message).to include("now on scene")
      end

      it "doesn't mark the assignment when already on scene" do
        assignment.stub on_scene_at: Time.zone.now
        expect(assignment).not_to receive :on_scene!
        subject.handle_command "arrived", matchers
        expect(outgoing_message.message).to include("already on scene")
      end
    end
    describe "responds to departed scene" do
      before(:each) { assignment.stub on_scene_at: Time.zone.now }
      it "marks the assignment when already on scene" do
        expect(assignment).to receive :departed_scene!
        subject.handle_command "departed", matchers
        expect(outgoing_message.message).to include("now departed")
      end

      it "doesn't mark the assignment when already departed" do
        assignment.stub departed_scene_at: Time.zone.now
        expect(assignment).not_to receive :departed_scene!
        subject.handle_command "departed", matchers
        expect(outgoing_message.message).to include("already departed")
      end

      it "doesn't mark the assignment when not on scene" do
        assignment.stub on_scene_at: nil
        expect(assignment).not_to receive :departed_scene!
        subject.handle_command "departed", matchers
        expect(outgoing_message.message).to include("aren't on scene")
      end
    end
    it "dispatches map info" do
      subject.handle_command "map", matchers
      expect(outgoing_message.message).to include(incident.address)
    end
    it "dispatches responder info" do
      subject.handle_command "responders", matchers
      expect(outgoing_message.message).to include("Responders")
    end
    it "dispatches commands" do
      subject.handle_command "commands", matchers
      expect(outgoing_message.message).to include("SMS Commands")
    end
    it "stores the message otherwise" do
      allow(incoming_message).to receive :save
      expect(incoming_message).to receive(:acknowledged=).with(false).ordered
      subject.handle_command "some other message", matchers
    end
  end
end