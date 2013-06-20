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

    it "should redirect if there is a valid dat incident already" do
      incident = FactoryGirl.create :incident
      dat = FactoryGirl.create :dat_incident, incident: incident

      get :new, incident_id: incident.to_param

      response.should redirect_to(action: :edit, incident_id: incident.to_param)
    end

    it "should render standalone" do
      get :new
      response.should be_success
    end

    it "should render under an incident" do
      incident = FactoryGirl.create :incident
      get :new, incident_id: incident.to_param
      response.should be_success
    end

  end

  describe "#edit" do
    before(:each) do
      @incident = FactoryGirl.create :incident
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
      @incident = FactoryGirl.create :incident
      @dat = FactoryGirl.build :dat_incident
      @lead = FactoryGirl.create :person
    end
    it "should allow creating" do
      expect {
        attrs = @dat.attributes
        attrs[:incident_attributes] = {id: @incident.id}
        attrs[:incident_attributes][:team_lead_attributes] = {person_id: @lead.id, role: 'team_lead', response: 'available'}

        post :create, incident_id: @incident.to_param, incidents_dat_incident: attrs
        pp controller.send(:resource).errors
        response.should redirect_to(@incident)
      }.to change(Incidents::DatIncident, :count).by(1)
    end
    it "should not change incident attributes" do
      attrs = @dat.attributes
      attrs[:incident_attributes] = {:incident_number => "15-555"}

      expect {
        post :create, incident_id: @incident.to_param, incidents_dat_incident: attrs
        response.should redirect_to(@incident)
      }.to_not change{@incident.reload.incident_number}
    end
  end

  context "without an existing incident" do
    it "should allow creating" do
      @incident = FactoryGirl.build :incident
      @dat = FactoryGirl.build :dat_incident
      @lead = FactoryGirl.create :person

      attrs = @dat.attributes
      attrs[:incident_attributes] = @incident.attributes
      attrs[:incident_attributes][:team_lead_attributes] = {person_id: @lead.id, role: 'team_lead', response: 'available'}

      expect {
        post :create, incidents_dat_incident: attrs
        response.should redirect_to(controller: :incidents, id: @incident.incident_number, action: :show)
      }.to change(Incidents::DatIncident, :count).by(1)
    end

    it "should not create without incident attributes" do
      @dat = FactoryGirl.build :dat_incident

      attrs = @dat.attributes
      attrs[:incident_attributes] = {}

      expect {
        post :create, incidents_dat_incident: attrs
        response.should_not be_redirect
        response.should be_success
      }.to_not change(Incidents::DatIncident, :count)
    end

  end

end
