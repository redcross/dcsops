require 'spec_helper'

describe Incidents::IncidentsController, :type => :controller do
  include LoggedIn

  describe "#needs_report" do
    it "displays the list" do
      grant_capability! 'submit_incident_report'
      inc = FactoryGirl.create :incident, region: @person.region
      inc2 = FactoryGirl.create :dat_incident
      expect(Incidents::Incident.count).to eq(2)

      get :needs_report, region_id: inc.region.to_param

      expect(response).to be_success
      expect(controller.send(:needs_report_collection)).to match_array([inc])
    end
  end

  describe "#show" do
    before(:each) { grant_capability! 'incidents_admin' }
    let(:inc) {FactoryGirl.create :incident, region: @person.region}
    it "should succeed with no cas or dat" do
      inc = FactoryGirl.create :incident, region: @person.region
      get :show, params: { id: inc.to_param, region_id: inc.region.to_param }
      expect(response).to be_success
    end

    it "should succeed in editable mode" do
      @person.region.update_attributes incidents_report_editable: true
      get :show, params: { id: inc.to_param, region_id: inc.region.to_param }
      expect(response).to be_success
    end

    it "should succeed with cas" do
      cas = FactoryGirl.create :cas_incident
      inc.link_to_cas_incident cas

      get :show, params: { id: inc.to_param, region_id: inc.region.to_param }
      expect(response).to be_success
    end

    it "should succeed with dat" do
      dat = FactoryGirl.create :dat_incident, incident: inc
      get :show, params: { id: inc.to_param, region_id: inc.region.to_param }
      expect(response).to be_success
    end

    it "should succeed rendering a partial" do
      get :show, params: { id: inc.to_param, region_id: inc.region.to_param, partial: 'details' }
      expect(response).to render_template(partial: '_details', layout: nil)
    end
  end

  describe '#mark_invalid' do
    before(:each) { grant_capability! 'submit_incident_report' }
    let!(:inc) {FactoryGirl.create :raw_incident, region: @person.region}
    before(:each) { allow(Incidents::Notifications::Notification).to receive :create_for_event }

    it "should succeed as get" do
      get :mark_invalid, id: inc.to_param, region_id: inc.region.to_param
      expect(response).to be_success
    end

    it "should succeed as post with valid params" do
      post :mark_invalid, id: inc.to_param, region_id: inc.region.to_param, incidents_incident: {reason_marked_invalid: 'invalid', narrative: 'Test'}
      expect(response).to redirect_to("/incidents/#{inc.region.to_param}/incidents/needs_report")
      inc.reload
      expect(inc.status).to eq('invalid')
      expect(inc.narrative).to eq('Test')
    end

    it "should not succeed as post without valid params" do
      expect {
        post :mark_invalid, id: inc.to_param, region_id: inc.region.to_param, incidents_incident: {incident_type: 'duplicate'}
        expect(response).to be_success
      }.to_not change{inc.reload.status}
    end

    it "should not succeed when the incident is closed" do
      inc.update_attribute :status, 'closed'
      expect {
        post :mark_invalid, id: inc.to_param, region_id: inc.region.to_param, incidents_incident: {incident_type: 'duplicate', narrative: 'Test'}
        expect(response).to redirect_to("/incidents/#{inc.region.to_param}/incidents/needs_report")
        expect(flash[:error]).not_to be_empty
      }.to_not change{inc.reload.status}
    end

    it "should trigger the invalid notification" do
      expect(Incidents::Notifications::Notification).to receive(:create_for_event).with(anything, 'incident_invalid')
      post :mark_invalid, id: inc.to_param, region_id: inc.region.to_param, incidents_incident: {reason_marked_invalid: 'invalid', narrative: 'Test'}
    end
  end

  describe "#close" do
    before(:each) { grant_capability! 'submit_incident_report' }
    let(:raw_incident) {FactoryGirl.create :raw_incident, region: @person.region}
    let(:complete_incident) {FactoryGirl.create :closed_incident, region: @person.region, status: 'open'}

    it "should succeed with a complete incident" do
      expect {
        post :close, params: { id: complete_incident.to_param, region_id: complete_incident.region.to_param }
        expect(response).to redirect_to("/incidents/#{complete_incident.region.to_param}/incidents/#{complete_incident.to_param}")
      }.to change{complete_incident.reload.status}.to('closed')
    end

    it "should not succeed with an incomplete incident" do
      expect {
        post :close, params: { id: raw_incident.to_param, region_id: raw_incident.region.to_param }
        expect(response).to redirect_to("/incidents/#{raw_incident.region.to_param}/incidents/#{raw_incident.to_param}/dat/edit?status=closed")
      }.to_not change{raw_incident.reload.status}
    end
  end

  describe "#reopen" do
    before(:each) { grant_capability! 'create_incident' }
    let(:complete_incident) {FactoryGirl.create :closed_incident, region: @person.region}

    it "should succeed" do
      expect {
        post :reopen, params: { id: complete_incident.to_param, region_id: complete_incident.region.to_param }
        expect(response).to redirect_to("/incidents/#{complete_incident.region.to_param}/incidents/#{complete_incident.to_param}")
      }.to change{complete_incident.reload.status}.to('open')
    end
  end

  describe "#create" do
    before(:each) { grant_capability! 'create_incident' }
    let(:shift_territory) {
      @person.region.shift_territories.first
    }
    let(:response_territory) { FactoryGirl.create :response_territory, region: @person.region }
    let(:params) {
      {incident_number: '14-123', date: Date.current.to_s, response_territory_id: response_territory.id}
    }
    before(:each) { allow(Incidents::Notifications::Notification).to receive :create_for_event }

    it "should succeed with valid params in editable mode" do
      @person.region.update_attributes incidents_report_editable: true
      expect {
        post :create, params: { incidents_incident: params, region_id: @person.region.to_param }
        expect(response).to redirect_to("/incidents/#{@person.region.to_param}/incidents/#{params[:incident_number]}")
      }.to change(Incidents::Incident, :count).by(1)
    end

    it "should trigger the created notification" do
      expect(Incidents::Notifications::Notification).to receive(:create_for_event).with(anything, 'new_incident')
      post :create, params: { incidents_incident: params, region_id: @person.region.to_param }
    end

    it "should succeed with valid params in normal mode" do
      expect {
        post :create, params: { incidents_incident: params, region_id: @person.region.to_param }
        expect(response).to redirect_to("/incidents/#{@person.region.to_param}/incidents/#{params[:incident_number]}/dat/new")
      }.to change(Incidents::Incident, :count).by(1)
    end

    describe "with incident number sequence" do

      let(:sequence) { FactoryGirl.create :incident_number_sequence, current_number: 333, format: '%<fy>04d-%<number>03d', current_year: FiscalYear.current.year }

      before(:each) do
        @person.region.update incident_number_sequence: sequence
        params.delete :incident_number
      end

      it "should succeed with valid params with sequence number generator" do
        expect {
          post :create, params: { incidents_incident: params, region_id: @person.region.to_param }
        }.to(change(Incidents::Incident, :count).by(1))
        inc = Incidents::Incident.last
        expect(inc.incident_number).to eq("#{FiscalYear.current.year}-334")
        expect(sequence.reload.current_number).to eq(334)
      end

      it "should not change incident sequence if the create is rejected" do
        params.delete :response_territory_id

        expect {
          expect {
            post :create, params: { incidents_incident: params, region_id: @person.region.to_param }
            expect(response).to be_success # Re-renders the create page rather than redirecting to the incident
          }.to_not(change(Incidents::Incident, :count))
        }.to_not(change{sequence.current_number})
      end

    end

  end

  describe '#activity' do
    before(:each) { grant_capability! 'cas_details'; PaperTrail.whodunnit = @person.id }

    it "should succeed" do
      get :activity, params: { region_id: @person.region.to_param }
      expect(response).to be_success
    end

  end

  describe '#resource_changes', versioning: true do
    before(:each) { PaperTrail.whodunnit = @person.id }
    before(:each) { grant_capability! 'cas_details'; PaperTrail.whodunnit = @person.id }

    it "should provide list of changes to incidents" do
      i = FactoryGirl.create :incident, region: @person.region
      i.update_attributes narrative: 'test'
      expect(i.versions).not_to be_blank

      get :activity, params: { region_id: i.region.to_param }
      
      expect(controller.resource_changes).to match_array(i.versions)
      expect(controller.resource_change_people.keys).to match_array([@person.id])
    end

    it "should not list changes for other regions" do
      region = FactoryGirl.create :region
      i = FactoryGirl.create :incident, region: region
      i.update_attributes narrative: 'test'
      expect(i.versions).not_to be_blank
      
      expect(controller.resource_changes).to match_array([])
    end

    it "should show only the changes for the given incident if specified" do
      i3 = FactoryGirl.create :incident, region: @person.region
      i3.update_attributes narrative: 'test123'

      i = FactoryGirl.create :incident, region: @person.region
      i.update_attributes narrative: 'test'
      expect(i.versions).not_to be_blank

      get :show, params: { id: i.to_param, region_id: i.region.to_param }
      
      expect(controller.resource_changes).to match_array(i.versions)
      expect(controller.resource_change_people.keys).to match_array([@person.id])
    end
  end

end
