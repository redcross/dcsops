require 'spec_helper'

describe Incidents::EventLogsController do
  include LoggedIn
  render_views
  before(:each) { grant_role! :submit_incident_report }

  let!(:incident) { FactoryGirl.create :incident, chapter: @person.chapter }

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
      get :new, {incident_id: incident.to_param, chapter_id: incident.chapter.to_param}
      response.should render_template('new')
      response.should render_template(layout: 'application')
    end

    it "renders without layout when xhr" do
      xhr :get, :new, {incident_id: incident.to_param, chapter_id: incident.chapter.to_param}
      response.should render_template('new')
      response.should render_template(layout: nil)
    end

  end

  describe "#edit" do

    let!(:log) { FactoryGirl.create :event_log, incident: incident }

    it "renders normally" do
      get :edit, {incident_id: incident.to_param, chapter_id: incident.chapter.to_param, id: log.to_param}
      response.should render_template('edit')
      response.should render_template(layout: 'application')
    end

    it "renders without layout when xhr" do
      xhr :get, :edit, {incident_id: incident.to_param, chapter_id: incident.chapter.to_param, id: log.to_param}
      response.should render_template('edit')
      response.should render_template(layout: nil)
    end

  end

  describe '#create' do
    it "creates with a valid object" do
      expect {
        post :create, {incident_id: incident.to_param, chapter_id: incident.chapter.to_param, :incidents_event_log => valid_attributes}
      }.to change(Incidents::EventLog, :count).by(1)
      response.should_not be_error
    end  

    context "when HTML" do
      it "redirects to the incident when valid" do
        post :create, {incident_id: incident.to_param, chapter_id: incident.chapter.to_param, :incidents_event_log => valid_attributes}
        response.should redirect_to(controller: 'incidents/incidents', id: incident.to_param, action: :show, anchor: 'inc-timeline')
      end

      it "renders new with layout when invalid" do
        post :create, {incident_id: incident.to_param, chapter_id: incident.chapter.to_param, :incidents_event_log => invalid_attributes}
        response.should be_success
        response.should render_template('new')
        response.should render_template(layout: 'application')
      end
    end

    context "when JS" do
      it "triggers the incident page refresh" do
        xhr :post, :create, {incident_id: incident.to_param, chapter_id: incident.chapter.to_param, :incidents_event_log => valid_attributes}
        response.should render_template('update')
      end

      it "renders the form within javascript when invalid" do
        xhr :post, :create, {incident_id: incident.to_param, chapter_id: incident.chapter.to_param, :incidents_event_log => invalid_attributes}
        response.should render_template('edit')
        response.should render_template(partial: '_form.html')
        response.should render_template(layout: nil)
      end
    end
  end

  describe '#destroy' do
    let!(:log) { FactoryGirl.create :event_log, incident: incident }

    it "destroys the object" do
      expect {
        delete :destroy, {incident_id: incident.to_param, chapter_id: incident.chapter.to_param, id: log.to_param}
      }.to change(Incidents::EventLog, :count).by(-1)
      expect {
        log.reload
      }.to raise_error(ActiveRecord::RecordNotFound)
    end

    it "when HTML, redirects to the incident" do
      delete :destroy, {incident_id: incident.to_param, chapter_id: incident.chapter.to_param, id: log.to_param}
      response.should redirect_to(incidents_chapter_incident_path(incident.chapter, incident))
    end

    it "when JS, triggers the incident page refresh" do
      xhr :delete, :destroy, {incident_id: incident.to_param, chapter_id: incident.chapter.to_param, id: log.to_param}
      response.should render_template('update')
    end
  end

end
