require 'spec_helper'

describe Incidents::ResponderMessageService do
  let(:chapter) { FactoryGirl.build_stubbed :chapter}
  let(:incident) { FactoryGirl.build_stubbed :incident, chapter: chapter }
  let(:assignment) { FactoryGirl.build_stubbed :responder_assignment, incident: incident }
  let(:incoming_message) { FactoryGirl.build_stubbed :incoming_responder_message, message: "commands" }
  subject { Incidents::ResponderMessageService.new(incoming_message) }
  before(:each) {
    subject.stub assignment: assignment
    subject.stub :short_url do |arg|
      arg
    end
  }

  describe '#reply' do
    it "checks that person is assigned to an open incident" do
      subject.stub open_assignment_for_person: nil
      response = subject.reply
      response.message.should include("not currently assigned")
    end

    it "calls handle_command" do
      subject.stub open_assignment_for_person: assignment
      incoming_message.stub :save
      response = subject.reply
      response.message.should_not be_blank
    end
  end

  describe '#open_assignment_for_person' do
    it "returns an assignment" do
      ra = FactoryGirl.create :responder_assignment
      subject.open_assignment_for_person(ra.person).should == ra
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
      outgoing_message.message.should include(incident.incident_number)
    end
    describe "dispatches on scene" do
      it "marks the assignment" do
        assignment.should_receive :on_scene!
        subject.handle_command "arrived", matchers
        outgoing_message.message.should include("now on scene")
      end

      it "doesn't mark the assignment when already on scene" do
        assignment.stub on_scene_at: Time.zone.now
        assignment.should_not_receive :on_scene!
        subject.handle_command "arrived", matchers
        outgoing_message.message.should include("already on scene")
      end
    end
    describe "responds to departed scene" do
      before(:each) { assignment.stub on_scene_at: Time.zone.now }
      it "marks the assignment when already on scene" do
        assignment.should_receive :departed_scene!
        subject.handle_command "departed", matchers
        outgoing_message.message.should include("now departed")
      end

      it "doesn't mark the assignment when already departed" do
        assignment.stub departed_scene_at: Time.zone.now
        assignment.should_not_receive :departed_scene!
        subject.handle_command "departed", matchers
        outgoing_message.message.should include("already departed")
      end

      it "doesn't mark the assignment when not on scene" do
        assignment.stub on_scene_at: nil
        assignment.should_not_receive :departed_scene!
        subject.handle_command "departed", matchers
        outgoing_message.message.should include("aren't on scene")
      end
    end
    it "dispatches map info" do
      subject.handle_command "map", matchers
      outgoing_message.message.should include(incident.address)
    end
    it "dispatches responder info" do
      subject.handle_command "responders", matchers
      outgoing_message.message.should include("Responders")
    end
    it "dispatches commands" do
      subject.handle_command "commands", matchers
      outgoing_message.message.should include("SMS Commands")
    end
    it "stores the message otherwise" do
      incoming_message.stub :save
      incoming_message.should_receive(:acknowledged=).with(false).ordered
      subject.handle_command "some other message", matchers
    end
  end
end