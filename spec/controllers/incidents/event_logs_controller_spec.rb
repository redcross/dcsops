require 'spec_helper'

describe Incidents::EventLogsController, :type => :controller do
  include LoggedIn
  render_views
  before(:each) { grant_capability! :submit_incident_report }

  let!(:incident) { FactoryGirl.create :incident, region: @person.region }

  let(:modal_name) {'edit-modal'}

  let(:valid_object) { FactoryGirl.build :event_log }
  let(:valid_attributes) { 
    valid_object.attributes
  }

  let(:invalid_attributes) {
    valid_attributes.dup.tap{|h|
      h.delete 'event'
    }
  }

  describe "#new" do

    it "renders normally" do
      get :new, params: { incident_id: incident.to_param, region_id: incident.region.to_param }
      expect(response).to render_template('new')
      expect(response).to render_template(layout: 'application')
    end

    it "renders without layout when xhr" do
      get :new, xhr: true, params: {incident_id: incident.to_param, region_id: incident.region.to_param}
      expect(response).to render_template('new')
      expect(response).to render_template(layout: nil)
    end

  end

  describe "#edit" do

    let!(:log) { FactoryGirl.create :event_log, incident: incident }

    it "renders normally" do
      get :edit, params: { incident_id: incident.to_param, region_id: incident.region.to_param, id: log.to_param }
      expect(response).to render_template('edit')
      expect(response).to render_template(layout: 'application')
    end

    it "renders without layout when xhr" do
      get :edit, xhr: true, params: {incident_id: incident.to_param, region_id: incident.region.to_param, id: log.to_param}
      expect(response).to render_template('edit')
      expect(response).to render_template(layout: nil)
    end

  end

  describe '#create' do
    it "creates with a valid object" do
      expect {
        post :create, params: { incident_id: incident.to_param, region_id: incident.region.to_param, :incidents_event_log => valid_attributes }
      }.to change(Incidents::EventLog, :count).by(1)
      expect(response).not_to be_server_error
    end  

    context "when HTML" do
      it "redirects to the incident when valid" do
        post :create, params: { incident_id: incident.to_param, region_id: incident.region.to_param, :incidents_event_log => valid_attributes }
        expect(response).to redirect_to(controller: 'incidents/incidents', id: incident.to_param, action: :show, anchor: 'inc-timeline')
      end

      it "renders new with layout when invalid" do
        post :create, params: { incident_id: incident.to_param, region_id: incident.region.to_param, :incidents_event_log => invalid_attributes }
        expect(response).to be_successful
        expect(response).to render_template('new')
        expect(response).to render_template(layout: 'application')
      end
    end

    context "when JS" do
      it "triggers the incident page refresh" do
        post :create, xhr: true, params: {incident_id: incident.to_param, region_id: incident.region.to_param, :incidents_event_log => valid_attributes}
        expect(response).to render_template('update')
      end

      it "renders the form within javascript when invalid" do
        post :create, xhr: true, params: {incident_id: incident.to_param, region_id: incident.region.to_param, :incidents_event_log => invalid_attributes}
        expect(response).to render_template('edit')
        expect(response).to render_template(partial: '_form.html')
        expect(response).to render_template(layout: nil)
      end
    end
  end

  describe '#destroy' do
    let!(:log) { FactoryGirl.create :event_log, incident: incident }

    it "destroys the object" do
      expect {
        delete :destroy, params: { incident_id: incident.to_param, region_id: incident.region.to_param, id: log.to_param }
      }.to change(Incidents::EventLog, :count).by(-1)
      expect {
        log.reload
      }.to raise_error(ActiveRecord::RecordNotFound)
    end

    it "when HTML, redirects to the incident" do
      delete :destroy, params: { incident_id: incident.to_param, region_id: incident.region.to_param, id: log.to_param }
      expect(response).to redirect_to(incidents_region_incident_path(incident.region, incident))
    end

    it "when JS, triggers the incident page refresh" do
      delete :destroy, xhr: true, params: {incident_id: incident.to_param, region_id: incident.region.to_param, id: log.to_param}
      expect(response).to render_template('update')
    end
  end

end
