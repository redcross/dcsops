require 'spec_helper'

describe Incidents::NotificationsController do
  include LoggedIn
  render_views
  before(:each) { @person.chapter.incidents_use_escalation_levels = true; @person.chapter.save!; grant_role! :submit_incident_report }
  before(:each) { Incidents::Notifications::Notification.stub :create }

  let!(:incident) { FactoryGirl.create :incident, chapter: @person.chapter }
  let(:event) { FactoryGirl.create :event, chapter: incident.chapter }

  let(:modal_name) {'edit-modal'}

  let(:message) { Faker::Lorem.sentence }
  let(:valid_attributes) { {event_id: event.id, message: message} }
  let(:invalid_attributes) {
    valid_attributes.dup.tap{|h|
      h.delete :'event_id'
    }
  }

  describe "#new" do

    it "renders normally" do
      get :new, {incident_id: incident.to_param, chapter_id: incident.chapter.to_param}
      response.should render_template('new')
      response.should render_template(partial: '_form')
      response.should render_template(layout: 'application')
    end

    it "renders without layout when xhr" do
      xhr :get, :new, {incident_id: incident.to_param, chapter_id: incident.chapter.to_param}
      response.should render_template('new')
      response.should render_template(layout: nil)
    end

    it "raises when the user doesn't have permission" do
      @person.position_memberships.delete_all
      @person.reload
      expect {
        get :new, {incident_id: incident.to_param, chapter_id: incident.chapter.to_param}
      }.to raise_error
    end

    it "redirects if the incident is closed" do
      incident.update_attribute :status, 'closed'
      get :new, {incident_id: incident.to_param, chapter_id: incident.chapter.to_param}
      response.should redirect_to(incidents_chapter_incident_path(incident.chapter, incident))
      flash[:error].should_not be_blank
    end
  end

  describe '#create' do
    it "creates with a valid object" do
      Incidents::Notifications::Notification.should_receive(:create).with(incident, event, {message: message})
      expect {
        post :create, {incident_id: incident.to_param, chapter_id: incident.chapter.to_param, :incidents_notifications_message => valid_attributes}
      }.to change(Incidents::EventLog, :count).by(1)
      response.should_not be_error
      incident.reload
      incident.notification_level_id.should == event.id
      incident.notification_level_message.should == message
    end  

    context "when HTML" do
      it "redirects to the incident when valid" do
        post :create, {incident_id: incident.to_param, chapter_id: incident.chapter.to_param, :incidents_notifications_message => valid_attributes}
        response.should redirect_to(controller: 'incidents/incidents', id: incident.to_param, action: :show, anchor: "inc-details")
      end

      it "renders new with layout when invalid" do
        post :create, {incident_id: incident.to_param, chapter_id: incident.chapter.to_param, :incidents_notifications_message => invalid_attributes}
        response.should be_success
        response.should render_template('new')
        response.should render_template(layout: 'application')
      end
    end

    context "when JS" do
      it "triggers the incident page refresh" do
        xhr :post, :create, {incident_id: incident.to_param, chapter_id: incident.chapter.to_param, :incidents_notifications_message => valid_attributes}
        response.should render_template('update')
      end

      it "renders the form within javascript when invalid" do
        xhr :post, :create, {incident_id: incident.to_param, chapter_id: incident.chapter.to_param, :incidents_notifications_message => invalid_attributes}
        response.should render_template('edit')
        response.should render_template(partial: '_form.html')
        response.should render_template(layout: nil)
      end
    end
  end

end
