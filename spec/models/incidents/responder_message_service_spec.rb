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

  describe '#handle_command' do
    it "dispatches incident info" do
      subject.should_receive :handle_incident_info
      subject.handle_command "incident"
    end
    it "dispatches on scene" do
      subject.should_receive :handle_on_scene
      subject.handle_command "arrived"
    end
    it "dispatches departed scene" do
      subject.should_receive :handle_departed_scene
      subject.handle_command "departed"
    end
    it "dispatches map info" do
      subject.should_receive :handle_incident_map
      subject.handle_command "map"
    end
    it "dispatches responder info" do
      subject.should_receive :handle_responders
      subject.handle_command "responders"
    end
    it "dispatches commands" do
      subject.should_receive :handle_help
      subject.handle_command "commands"
    end
    it "stores the message otherwise" do
      incoming_message.stub :save
      incoming_message.should_receive(:acknowledged=).with(true).ordered
      incoming_message.should_receive(:acknowledged=).with(false).ordered
      subject.handle_command "some other message"
    end
  end

  describe "message handlers" do
    let(:outgoing_message) { Incidents::ResponderMessage.new }
    before(:each) {
      subject.stub response: outgoing_message
    }

    it "responds with help" do
      subject.handle_help
      outgoing_message.message.should include("SMS Commands")
    end

    it "responds with map" do
      subject.handle_incident_map
      outgoing_message.message.should include(incident.address)
    end

    it "responds with responders" do
      subject.handle_responders
      outgoing_message.message.should include("Responders")
    end

    it "responds with incident info" do
      subject.handle_incident_info
      outgoing_message.message.should include(incident.incident_number)
    end

    describe "responds to on scene" do
      it "marks the assignment" do
        assignment.should_receive :on_scene!
        subject.handle_on_scene
        outgoing_message.message.should include("now on scene")
      end

      it "doesn't mark the assignment when already on scene" do
        assignment.stub on_scene_at: Time.zone.now
        assignment.should_not_receive :on_scene!
        subject.handle_on_scene
        outgoing_message.message.should include("already on scene")
      end
    end

    describe "responds to departed scene" do
      before(:each) { assignment.stub on_scene_at: Time.zone.now }
      it "marks the assignment when already on scene" do
        assignment.should_receive :departed_scene!
        subject.handle_departed_scene
        outgoing_message.message.should include("now departed")
      end

      it "doesn't mark the assignment when already departed" do
        assignment.stub departed_scene_at: Time.zone.now
        assignment.should_not_receive :departed_scene!
        subject.handle_departed_scene
        outgoing_message.message.should include("already departed")
      end

      it "doesn't mark the assignment when not on scene" do
        assignment.stub on_scene_at: nil
        assignment.should_not_receive :departed_scene!
        subject.handle_departed_scene
        outgoing_message.message.should include("aren't on scene")
      end
    end
  end
end