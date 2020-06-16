require 'spec_helper'

describe Incidents::NotificationsController, :type => :controller do
  include LoggedIn
  render_views
  before(:each) { @person.region.incidents_use_escalation_levels = true; @person.region.save!; grant_capability! :submit_incident_report }
  before(:each) { allow(Incidents::Notifications::Notification).to receive :create }

  let!(:incident) { FactoryGirl.create :incident, region: @person.region }
  let(:event) { FactoryGirl.create :event, region: incident.region }

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
      get :new, params: { incident_id: incident.to_param, region_id: incident.region.to_param }
      expect(response).to render_template('new')
      expect(response).to render_template(partial: '_form')
      expect(response).to render_template(layout: 'application')
    end

    it "renders without layout when xhr" do
      get :new, xhr: true, params: {incident_id: incident.to_param, region_id: incident.region.to_param}
      expect(response).to render_template('new')
      expect(response).to render_template(layout: nil)
    end

    it "raises when the user doesn't have permission" do
      @person.position_memberships.delete_all
      @person.reload
      expect {
        get :new, params: { incident_id: incident.to_param, region_id: incident.region.to_param }
      }.to raise_error
    end

    it "redirects if the incident is closed" do
      incident.update_attribute :status, 'closed'
      get :new, params: { incident_id: incident.to_param, region_id: incident.region.to_param }
      expect(response).to redirect_to(incidents_region_incident_path(incident.region, incident))
      expect(flash[:error]).not_to be_blank
    end
  end

  describe '#create' do
    it "creates with a valid object" do
      expect(Incidents::Notifications::Notification).to receive(:create).with(incident, event, {message: message})
      expect {
        post :create, params: { incident_id: incident.to_param, region_id: incident.region.to_param, :incidents_notifications_message => valid_attributes }
      }.to change(Incidents::EventLog, :count).by(1)
      expect(response).not_to be_error
      incident.reload
      expect(incident.notification_level_id).to eq(event.id)
      expect(incident.notification_level_message).to eq(message)
    end  

    context "when HTML" do
      it "redirects to the incident when valid" do
        post :create, params: { incident_id: incident.to_param, region_id: incident.region.to_param, :incidents_notifications_message => valid_attributes }
        expect(response).to redirect_to(controller: 'incidents/incidents', id: incident.to_param, action: :show, anchor: "inc-details")
      end

      it "renders new with layout when invalid" do
        post :create, params: { incident_id: incident.to_param, region_id: incident.region.to_param, :incidents_notifications_message => invalid_attributes }
        expect(response).to be_success
        expect(response).to render_template('new')
        expect(response).to render_template(layout: 'application')
      end
    end

    context "when JS" do
      it "triggers the incident page refresh" do
        post :create, xhr: true, params: {incident_id: incident.to_param, region_id: incident.region.to_param, :incidents_notifications_message => valid_attributes}
        expect(response).to render_template('update')
      end

      it "renders the form within javascript when invalid" do
        post :create, xhr: true, params: {incident_id: incident.to_param, region_id: incident.region.to_param, :incidents_notifications_message => invalid_attributes}
        expect(response).to render_template('edit')
        expect(response).to render_template(partial: '_form.html')
        expect(response).to render_template(layout: nil)
      end
    end
  end

end
