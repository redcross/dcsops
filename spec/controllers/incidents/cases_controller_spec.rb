require 'spec_helper'

describe Incidents::CasesController do
  include LoggedIn
  render_views
  before(:each) { @person.chapter.incidents_collect_case_details = true; @person.chapter.save!; grant_role! :submit_incident_report }

  let!(:incident) { FactoryGirl.create :incident }

  let(:modal_name) {'edit-modal'}

  let(:valid_object) { FactoryGirl.build :case_with_assistance }
  let(:assistance_item_attributes) {
    valid_object.case_assistance_items.map{|ci| ci.attributes.slice('price_list_item_id', 'quantity')}
  }
  let(:valid_attributes) { 
    valid_object.attributes.merge(case_assistance_items_attributes: assistance_item_attributes, 'cac_number' => '4111-1111-1111-1111')
  }

  let(:invalid_attributes) {
    valid_attributes.dup.tap{|h|
      h.delete 'first_name'
      h.delete 'cac_number'
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

    let!(:kase) { FactoryGirl.create :case, incident: incident }

    it "renders normally" do
      get :edit, {incident_id: incident.to_param, chapter_id: incident.chapter.to_param, id: kase.to_param}
      response.should render_template('edit')
      response.should render_template(layout: 'application')
    end

    it "renders without layout when xhr" do
      xhr :get, :edit, {incident_id: incident.to_param, chapter_id: incident.chapter.to_param, id: kase.to_param}
      response.should render_template('edit')
      response.should render_template(layout: nil)
    end

  end

  describe '#create' do
    it "creates with a valid object" do
      expect {
        post :create, {incident_id: incident.to_param, chapter_id: incident.chapter.to_param, :incidents_case => valid_attributes}
      }.to change(Incidents::Case, :count).by(1)
      response.should_not be_error
    end  

    context "when HTML" do
      it "redirects to the incident when valid" do
        post :create, {incident_id: incident.to_param, chapter_id: incident.chapter.to_param, :incidents_case => valid_attributes}
        response.should redirect_to(controller: 'incidents/incidents', id: incident.to_param, action: :show, anchor: "inc-cases")
      end

      it "renders new with layout when invalid" do
        post :create, {incident_id: incident.to_param, chapter_id: incident.chapter.to_param, :incidents_case => invalid_attributes}
        response.should be_success
        response.should render_template('new')
        response.should render_template(layout: 'application')
      end
    end

    context "when JS" do
      it "triggers the incident page refresh" do
        xhr :post, :create, {incident_id: incident.to_param, chapter_id: incident.chapter.to_param, :incidents_case => valid_attributes}
        response.should render_template('update')
      end

      it "renders the form within javascript when invalid" do
        xhr :post, :create, {incident_id: incident.to_param, chapter_id: incident.chapter.to_param, :incidents_case => invalid_attributes}
        response.should render_template('edit')
        response.should render_template(partial: '_form.html')
        response.should render_template(layout: nil)
      end
    end
  end

  describe '#destroy' do
    let!(:kase) { FactoryGirl.create :case, incident: incident }

    it "destroys the object" do
      expect {
        delete :destroy, {incident_id: incident.to_param, chapter_id: incident.chapter.to_param, id: kase.to_param}
      }.to change(Incidents::Case, :count).by(-1)
      expect {
        kase.reload
      }.to raise_error(ActiveRecord::RecordNotFound)
    end

    it "when HTML, redirects to the incident" do
      delete :destroy, {incident_id: incident.to_param, chapter_id: incident.chapter.to_param, id: kase.to_param}
      response.should redirect_to(incidents_chapter_incident_path(incident.chapter, incident))
    end

    it "when JS, triggers the incident page refresh" do
      xhr :delete, :destroy, {incident_id: incident.to_param, chapter_id: incident.chapter.to_param, id: kase.to_param}
      response.should render_template('update')
    end
  end

end
