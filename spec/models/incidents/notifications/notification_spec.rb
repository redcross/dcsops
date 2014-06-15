require 'spec_helper'

describe Incidents::Notifications::Notification do
  let(:chapter) { FactoryGirl.build_stubbed :chapter }
  let(:event) { FactoryGirl.build_stubbed :event }
  let(:incident) { FactoryGirl.build_stubbed :incident }
  let(:person) { FactoryGirl.build_stubbed :person }
  let(:message) { "Test Message" }
  let(:notification) { Incidents::Notifications::Notification.new(incident, event, message) }

  after(:each) { ActionMailer::Base.deliveries.clear }

  describe '#roles_for_event' do
    let(:trigger) { FactoryGirl.build_stubbed :trigger, role: role }
    let(:role) { FactoryGirl.build_stubbed :notification_role, chapter: chapter }

    it "Should return hash of information" do
      notification.stub triggers_for_event: [trigger]
      role.stub members: [person] 
      data = notification.roles_for_event(event)
      data.should have(1).item

      data = data.first
      data[:template].should == trigger.template
      data[:use_sms].should == true
      people = data[:people]
      people.should be_a(Array)
      people.should =~ [person]
    end
  end

  describe '#match_scope' do
    let(:role) { FactoryGirl.build_stubbed :notification_role, chapter: chapter }
    let(:scope) {mock_model Incidents::Notifications::RoleScope}
    it "is true when role has no scopes" do
      notification.match_scope(role).should be_true
    end
    it "is true when role scope is region" do
      scope.stub level: 'region'
      role.stub role_scopes: [scope]
      notification.match_scope(role).should be_true
    end
    it "is true when role scope is county and matches" do
      scope.stub level: 'county'
      scope.stub value: "#{incident.county}, #{incident.state}"
      role.stub role_scopes: [scope]
      notification.match_scope(role).should be_true
    end
    it "is false when role scope is county and doesn't match" do
      scope.stub level: 'county'
      scope.stub value: "Other County, #{incident.state}"
      role.stub role_scopes: [scope]
      notification.match_scope(role).should be_false
    end
  end

  describe '#plan_messages' do
    let(:person2) { FactoryGirl.build_stubbed :person }

    it "Plans one message" do
      data = [{template: 'test', use_sms: false, people: [person]}]
      messages = notification.plan_messages data
      messages.should =~ [{person: person, template: 'test', use_sms: false}]
    end

    it "Plans two messages" do
      data = [{template: 'test', use_sms: false, people: [person, person2]}]
      messages = notification.plan_messages data
      messages.should =~ [{person: person, template: 'test', use_sms: false}, {person: person2, template: 'test', use_sms: false}]
    end

    it "Handles conflicting roles for SMS" do
      data = [{template: 'test', use_sms: false, people: [person]}, {template: 'test', use_sms: true, people: [person]}]
      messages = notification.plan_messages data
      messages.should =~ [{person: person, template: 'test', use_sms: true}]
    end

    it "Handles conflicting roles for template" do
      data = [{template: 'notification', use_sms: false, people: [person]}, {template: 'mobilization', use_sms: true, people: [person]}]
      messages = notification.plan_messages data
      messages.should =~ [{person: person, template: 'mobilization', use_sms: true}]
    end
  end

  describe '#deliver_message', type: :mailer do
    it "Delivers email" do
      data = {person: person, template: 'mobilization', use_sms: false}
      Incidents::Notifications::Mailer.should_receive(:notify_event).with(person, false, event, incident, 'mobilization', message).once.and_return(double deliver: true)
      notification.deliver_message data
    end

    it "Delivers sms if use_sms is specified" do
      person.stub sms_addresses: ['test@vtext.com']
      data = {person: person, template: 'mobilization', use_sms: true}
      Incidents::Notifications::Mailer.should_receive(:notify_event).with(person, false, event, incident, 'mobilization', message).once.and_return(double deliver: true)
      Incidents::Notifications::Mailer.should_receive(:notify_event).with(person, true, event, incident, 'mobilization', message).and_return(double deliver: true)
      notification.deliver_message data
    end
  end

  describe '#create', type: :mailer do
    it "works completely" do
      person = FactoryGirl.create :person
      role = FactoryGirl.create :notification_role, positions: [person.positions.first], chapter: person.chapter
      event = FactoryGirl.create :event, chapter: person.chapter, event: 'new_incident'
      incident = FactoryGirl.create :incident, chapter: person.chapter
      trigger = FactoryGirl.create :trigger, role: role, event: event, template: 'notification'

      Incidents::Notifications::Notification.create incident, event, message

      ActionMailer::Base.deliveries.should have(1).item
    end
  end
end
