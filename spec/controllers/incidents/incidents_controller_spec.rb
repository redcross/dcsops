require 'spec_helper'

describe Incidents::IncidentsController do
  include LoggedIn

  describe "#needs_report" do
    it "displays the list" do
      grant_role! 'submit_incident_report'
      inc = FactoryGirl.create :incident, chapter: @person.chapter
      inc2 = FactoryGirl.create :dat_incident
      Incidents::Incident.count.should == 2

      get :needs_report

      response.should be_success
      controller.send(:needs_report_collection).should =~ [inc]
    end
  end

  describe "#link_cas" do
    before(:each) { grant_role! 'cas_admin' }
    it "displays the list" do
      cas = FactoryGirl.create :cas_incident, chapter: @person.chapter
      cas2 = FactoryGirl.create :cas_incident, chapter: @person.chapter
      inc = FactoryGirl.create :incident, chapter: @person.chapter
      inc2 = FactoryGirl.create :incident, chapter: @person.chapter

      inc.link_to_cas_incident(cas2)

      get :link_cas

      response.should be_success
      controller.send(:cas_incidents_to_link).should =~ [cas]
    end

    it "can link an incident" do
      cas = FactoryGirl.create :cas_incident
      inc = FactoryGirl.create :incident, chapter: @person.chapter

      post :link_cas, cas_id: cas.id, incident_id: inc.id
      response.should be_success

      inc.reload.cas_incident_number.should == cas.cas_incident_number
    end

    it "can promote to an incident" do
      cas = FactoryGirl.create :cas_incident
      FactoryGirl.create :county, name: cas.county_name

      Geokit::Geocoders::GoogleGeocoder3.should_receive(:geocode).and_return(double lat: Faker::Address.latitude, lng: Faker::Address.longitude)

      expect {
        post :link_cas, cas_id: cas.id, commit: 'Promote to Incident'
        response.should be_success
      }.to change(Incidents::Incident, :count).by(1)

      Incidents::Incident.where(cas_incident_number: cas.cas_incident_number).first.should_not be_nil
    end

  end

  describe "#show" do
    before(:each) { grant_role! 'incidents_admin' }
    let(:inc) {FactoryGirl.create :incident, chapter: @person.chapter}
    it "should succeed with no cas or dat" do
      inc = FactoryGirl.create :incident, chapter: @person.chapter
      get :show, id: inc.to_param
      response.should be_success
    end

    it "should succeed in editable mode" do
      @person.chapter.update_attributes incidents_report_editable: true
      get :show, id: inc.to_param
      response.should be_success
    end

    it "should succeed with cas" do
      cas = FactoryGirl.create :cas_incident
      inc.link_to_cas_incident cas

      get :show, id: inc.to_param
      response.should be_success
    end

    it "should succeed with dat" do
      dat = FactoryGirl.create :dat_incident, incident: inc
      get :show, id: inc.to_param
      response.should be_success
    end

    it "should succeed rendering a partial" do
      get :show, id: inc.to_param, partial: 'details'
      response.should render_template(partial: '_details', layout: nil)
    end
  end

  describe '#mark_invalid' do
    before(:each) { grant_role! 'submit_incident_report' }
    let!(:inc) {FactoryGirl.create :raw_incident, chapter: @person.chapter}

    it "should succeed as get" do
      get :mark_invalid, id: inc.to_param
      response.should be_success
    end

    it "should succeed as post with valid params" do
      post :mark_invalid, id: inc.to_param, incidents_incident: {incident_type: 'invalid', narrative: 'Test'}
      response.should redirect_to('/incidents/incidents/needs_report')
      inc.reload
      inc.status.should == 'invalid'
      inc.narrative.should == 'Test'
    end

    it "should not succeed as post without valid params" do
      expect {
        post :mark_invalid, id: inc.to_param, incidents_incident: {incident_type: 'duplicate'}
        response.should be_success
      }.to_not change{inc.reload.status}
    end
  end

  describe "#close" do
    before(:each) { grant_role! 'submit_incident_report' }
    let(:raw_incident) {FactoryGirl.create :raw_incident, chapter: @person.chapter}
    let(:complete_incident) {FactoryGirl.create :closed_incident, chapter: @person.chapter, status: 'open'}

    it "should succeed with a complete incident" do
      expect {
        post :close, id: complete_incident.to_param
        response.should redirect_to("/incidents/incidents/#{complete_incident.to_param}")
      }.to change{complete_incident.reload.status}.to('closed')
    end

    it "should not succeed with an incomplete incident" do
      expect {
        post :close, id: raw_incident.to_param
        response.should redirect_to("/incidents/incidents/#{raw_incident.to_param}/dat/edit?status=closed")
      }.to_not change{raw_incident.reload.status}
    end
  end

  describe "#reopen" do
    before(:each) { grant_role! 'create_incident' }
    let(:complete_incident) {FactoryGirl.create :closed_incident, chapter: @person.chapter}

    it "should succeed" do
      expect {
        post :reopen, id: complete_incident.to_param
        response.should redirect_to("/incidents/incidents/#{complete_incident.to_param}")
      }.to change{complete_incident.reload.status}.to('open')
    end
  end

  describe "#create" do
    before(:each) { grant_role! 'create_incident' }
    let(:area) {
      @person.chapter.counties.first
    }
    let(:params) {
      {incident_number: '14-123', area_id: area.id, date: Date.current.to_s}
    }

    it "should succeed with valid params in editable mode" do
      @person.chapter.update_attributes incidents_report_editable: true
      expect {
        post :create, incidents_incident: params
        response.should redirect_to("/incidents/incidents/#{params[:incident_number]}")
      }.to change(Incidents::Incident, :count).by(1)
    end

    it "should succeed with valid params in normal mode" do
      expect {
        post :create, incidents_incident: params
        response.should redirect_to("/incidents/incidents/#{params[:incident_number]}/dat/new")
      }.to change(Incidents::Incident, :count).by(1)
    end

    describe "with incident number sequence" do

      before(:each) do
         @person.chapter.update_attributes incidents_sequence_enabled: true, 
                                         incidents_sequence_number: 333,
                                         incidents_sequence_format: '%<fy_short>02d-%<number>03d', 
                                         incidents_sequence_year: FiscalYear.current.year
        params.delete :incident_number
      end

      it "should succeed with valid params with sequence number generator" do
        expect {
          post :create, incidents_incident: params
        }.to(change(Incidents::Incident, :count).by(1))
        inc = Incidents::Incident.last
        inc.incident_number.should == '14-334'
        @person.chapter.reload.incidents_sequence_number.should == 334
      end

      it "should not change incident sequence if the create is rejected" do
        params.delete :area_id

        expect {
          expect {
            post :create, incidents_incident: params
            response.should be_success # Re-renders the create page rather than redirecting to the incident
          }.to_not(change(Incidents::Incident, :count))
        }.to_not(change{@person.chapter.reload.incidents_sequence_number})
      end

    end

  end


end
