require 'spec_helper'

# This spec was generated by rspec-rails when you ran the scaffold generator.
# It demonstrates how one might use RSpec to specify the controller code that
# was generated by Rails when you ran the scaffold generator.
#
# It assumes that the implementation code is generated by the rails scaffold
# generator.  If you are using any extension libraries to generate different
# controller code, this generated spec may or may not pass.
#
# It only uses APIs available in rails and/or rspec-rails.  There are a number
# of tools you can use to make these specs even more expressive, but we're
# sticking to rails and rspec-rails APIs to keep things simple and stable.
#
# Compared to earlier versions of this generator, there is very limited use of
# stubs and message expectations in this spec.  Stubs are only used when there
# is no simpler way to get a handle on the object needed for the example.
# Message expectations are only used when there is no simpler way to specify
# that an instance is receiving a specific message.

describe Incidents::RespondersController, :type => :controller do
  include LoggedIn
  before(:each) {@person.region.incidents_enable_dispatch_console = true; @person.region.save!;}

  # This should return the minimal set of attributes required to create a valid
  # Incidents::Responder. As you add validations to Incidents::Responder, be sure to
  # adjust the attributes here as well.
  let(:valid_attributes) { FactoryGirl.build(:responder_assignment, incident: incident, person: person).attributes }

  # This should return the minimal set of values that should be in the session
  # in order to pass any filters (e.g. authentication) defined in
  # Incidents::RespondersController. Be sure to keep this updated too.
  let(:valid_session) { {} }

  let(:incident) { FactoryGirl.create :incident, region: @person.region }
  let(:person) { FactoryGirl.create :person, work_phone_carrier: FactoryGirl.create(:cell_carrier), region: incident.region }

  before :each do
    grant_capability! 'submit_incident_report'
  end

  describe "POST create" do
    describe "with valid params" do
      it "creates a new Incidents::Responder" do
        expect {
          post :create, params: { :incidents_responder_assignment => valid_attributes, incident_id: incident.to_param, region_id: incident.region.to_param }, session: valid_session
        }.to change(Incidents::ResponderAssignment, :count).by(1)
      end

      it "redirects to index" do
        post :create, params: { :incidents_responder_assignment => valid_attributes, incident_id: incident.to_param, region_id: incident.region.to_param }, session: valid_session
        expect(response).to redirect_to(incidents_region_incident_responders_url(incident.region, incident))
      end

      it "triggers the assignment mailers with a responding role" do
        client_stub = double :sms_client
        controller.stub sms_client: client_stub
        Bitly.stub(client: double(:shorten => double(short_url: "https://short.url")))
        expect(client_stub).to receive(:send_message).with(an_instance_of(Incidents::ResponderMessage))
        expect(Incidents::RespondersMailer).to receive(:assign_email).and_return(double deliver: true)
        post :create, params: { :incidents_responder_assignment => valid_attributes.merge({'role' => 'team_lead'}), incident_id: incident.to_param, region_id: incident.region.to_param, send_assignment_sms: true, send_assignment_email: true }, session: valid_session
      end

      it "triggers the assignment mailers with a non-responding role" do
        expect(Incidents::RespondersMailer).not_to receive(:assign_sms)
        expect(Incidents::RespondersMailer).not_to receive(:assign_email)
        post :create, params: { incidents_responder_assignment: valid_attributes.merge({'role' => 'not_available'}), incident_id: incident.to_param, region_id: incident.region.to_param, send_assignment_sms: true, send_assignment_email: true }, session: valid_session
      end
    end
  end

  describe "GET index" do
    it "should succeed" do
      get :index, params: { incident_id: incident.to_param, region_id: incident.region.to_param }
      expect(response).to be_successful
    end

    it "should set the flash if incident doesn't have a location" do
      incident.update_attributes lat: nil, lng: nil
      get :index, params: { incident_id: incident.to_param, region_id: incident.region.to_param }
      expect(response).to be_successful
      expect(flash.now[:error]).not_to be_empty
    end
  end

  describe "GET new" do
    it "should succeed" do
      get :new, params: { incident_id: incident.to_param, region_id: incident.region.to_param }
      expect(response).to be_successful

      expect(controller.send(:person)).to eq(nil)
    end

    it "should assign the person if given" do
      get :new, params: { incident_id: incident.to_param, region_id: incident.region.to_param, person_id: person.id }
      expect(response).to be_successful

      expect(controller.send(:person)).to eq(person)
      expect(controller.send(:resource).person_id).to eq(person.id)
    end
  end

  describe "POST update_status" do
    let!(:assignment) { FactoryGirl.create :responder_assignment, person: person, incident: incident }
    it "fails with an invalid value" do
      expect {
        post :update_status, params: {incident_id: incident.to_param, region_id: incident.region.to_param, id: assignment.id, status: 'whatever'}
      }.to_not change{assignment.reload.attributes}
    end
    it "updates dispatched at" do
      expect {
        post :update_status, params: {incident_id: incident.to_param, region_id: incident.region.to_param, id: assignment.id, status: 'dispatched'}
      }.to change{assignment.reload.dispatched_at}.from(nil)
    end
    it "updates on scene at" do
      expect {
        post :update_status, params: {incident_id: incident.to_param, region_id: incident.region.to_param, id: assignment.id, status: 'on_scene'}
      }.to change{assignment.reload.on_scene_at}.from(nil)
    end
    it "updates departed at" do
      expect {
        post :update_status, params: {incident_id: incident.to_param, region_id: incident.region.to_param, id: assignment.id, status: 'departed_scene'}
      }.to change{assignment.reload.departed_scene_at}.from(nil)
    end

    it "marks the incident as on scene" do
      post :update_status, params: {incident_id: incident.to_param, region_id: incident.region.to_param, id: assignment.id, status: 'on_scene'}
      on_scene = incident.event_logs.detect{|el| el.event == 'dat_on_scene'}
      expect(on_scene).not_to be_nil
    end

    it "doesn't mark the incident as on scene if it already is" do
      log = incident.event_logs.create event: 'dat_on_scene', event_time: Time.zone.now
      expect {
        post :update_status, params: {incident_id: incident.to_param, region_id: incident.region.to_param, id: assignment.id, status: 'on_scene'}
      }.to_not change{log.reload.attributes}
    end

    it "marks the incident as departed scene" do
      post :update_status, params: {incident_id: incident.to_param, region_id: incident.region.to_param, id: assignment.id, status: 'departed_scene'}
      dat_departed_scene = incident.event_logs.detect{|el| el.event == 'dat_departed_scene'}
      expect(dat_departed_scene).not_to be_nil
    end

    it "doesn't mark the incident as departed scene if this isn't the last responder" do
      FactoryGirl.create :responder_assignment, incident: incident, role: 'responder'
      expect {
        post :update_status, params: {incident_id: incident.to_param, region_id: incident.region.to_param, id: assignment.id, status: 'departed_scene'}
      }.to_not change(Incidents::EventLog, :count)
    end
  end


  it "should not allow records for duplicate people to be created"

end
