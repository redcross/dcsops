require 'spec_helper'

describe Incidents::DatIncidentsController do
  include LoggedIn



  # This should return the minimal set of attributes required to create a valid
  # Incidents::DatIncident. As you add validations to Incidents::DatIncident, be sure to
  # adjust the attributes here as well.
  let(:valid_attributes) { {  } }

  # This should return the minimal set of values that should be in the session
  # in order to pass any filters (e.g. authentication) defined in
  # Incidents::DatIncidentsController. Be sure to keep this updated too.
  let(:valid_session) { {} }

  describe "#new" do

    before(:each) do
      grant_role! :submit_incident_report
    end

    it "should redirect if there is a valid dat incident already" do
      grant_role! :incidents_admin
      incident = FactoryGirl.create :incident, chapter: @person.chapter
      dat = FactoryGirl.create :dat_incident, incident: incident

      get :new, incident_id: incident.to_param

      response.should redirect_to(action: :edit, incident_id: incident.to_param)
    end

    it "should render under an incident" do
      incident = FactoryGirl.create :incident, chapter: @person.chapter
      get :new, incident_id: incident.to_param
      response.should be_success
    end

  end

  describe "#edit" do
    before(:each) do
      grant_role! :incidents_admin
    end
    before(:each) do
      @incident = FactoryGirl.create :incident, chapter: @person.chapter
      @dat = FactoryGirl.create :dat_incident, incident: @incident
    end
    it "should render under an incident" do
      get :edit, incident_id: @incident.to_param
    end
    it "should not render standalone" do
      expect {
        get :edit, id: @dat.to_param
      }.to raise_error
    end
  end

  context "with an existing incident" do  
    before(:each) do
      grant_role! :submit_incident_report
    end

    before(:each) do
      @incident = FactoryGirl.create :incident, chapter: @person.chapter
      @dat = FactoryGirl.build :dat_incident
      @lead = FactoryGirl.create :person
      @vehicle = FactoryGirl.create :vehicle

      Incidents::IncidentReportFiled.stub(new: double(save: true))
    end

    let(:create_attrs) {
      attrs = @dat.attributes
      attrs[:incident_attributes] = {id: @incident.id}
      attrs[:incident_attributes][:team_lead_attributes] = {person_id: @lead.id, role: 'team_lead', response: 'available'}
      attrs[:vehicle_ids] = [@vehicle.id]
      attrs
    }

    it "should allow creating" do
      expect {
        post :create, incident_id: @incident.to_param, incidents_dat_incident: create_attrs
        response.should redirect_to(@incident)
      }.to change(Incidents::DatIncident, :count).by(1)
    end
    it "should not change incident attributes" do
      create_attrs[:incident_attributes].merge!( {:incident_number => "15-555"})
      expect {
        post :create, incident_id: @incident.to_param, incidents_dat_incident: create_attrs
        response.should redirect_to(@incident)
      }.to_not change{@incident.reload.incident_number}
    end
    it "should notify the report was filed" do
      Incidents::IncidentReportFiled.should_receive(:new).with(@incident, true).and_return(double(save: true))
      post :create, incident_id: @incident.to_param, incidents_dat_incident: create_attrs
    end
  end
end
