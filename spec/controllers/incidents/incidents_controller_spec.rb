require 'spec_helper'

describe Incidents::IncidentsController do
  include LoggedIn

  describe "#needs_report" do
    it "displays the list" do
      grant_role! 'submit_incident_report'
      inc = FactoryGirl.create :incident, chapter: @person.chapter
      inc2 = FactoryGirl.create :dat_incident
      Incidents::Incident.count.should == 2

      get :needs_report, chapter_id: inc.chapter.to_param

      response.should be_success
      controller.send(:needs_report_collection).should =~ [inc]
    end
  end

  describe "#show" do
    before(:each) { grant_role! 'incidents_admin' }
    let(:inc) {FactoryGirl.create :incident, chapter: @person.chapter}
    it "should succeed with no cas or dat" do
      inc = FactoryGirl.create :incident, chapter: @person.chapter
      get :show, id: inc.to_param, chapter_id: inc.chapter.to_param
      response.should be_success
    end

    it "should succeed in editable mode" do
      @person.chapter.update_attributes incidents_report_editable: true
      get :show, id: inc.to_param, chapter_id: inc.chapter.to_param
      response.should be_success
    end

    it "should succeed with cas" do
      cas = FactoryGirl.create :cas_incident
      inc.link_to_cas_incident cas

      get :show, id: inc.to_param, chapter_id: inc.chapter.to_param
      response.should be_success
    end

    it "should succeed with dat" do
      dat = FactoryGirl.create :dat_incident, incident: inc
      get :show, id: inc.to_param, chapter_id: inc.chapter.to_param
      response.should be_success
    end

    it "should succeed rendering a partial" do
      get :show, id: inc.to_param, chapter_id: inc.chapter.to_param, partial: 'details'
      response.should render_template(partial: '_details', layout: nil)
    end
  end

  describe '#mark_invalid' do
    before(:each) { grant_role! 'submit_incident_report' }
    let!(:inc) {FactoryGirl.create :raw_incident, chapter: @person.chapter}
    before(:each) { Incidents::Notifications::Notification.stub :create_for_event }

    it "should succeed as get" do
      get :mark_invalid, id: inc.to_param, chapter_id: inc.chapter.to_param
      response.should be_success
    end

    it "should succeed as post with valid params" do
      post :mark_invalid, id: inc.to_param, chapter_id: inc.chapter.to_param, incidents_incident: {incident_type: 'invalid', narrative: 'Test'}
      response.should redirect_to("/incidents/#{inc.chapter.to_param}/incidents/needs_report")
      inc.reload
      inc.status.should == 'invalid'
      inc.narrative.should == 'Test'
    end

    it "should not succeed as post without valid params" do
      expect {
        post :mark_invalid, id: inc.to_param, chapter_id: inc.chapter.to_param, incidents_incident: {incident_type: 'duplicate'}
        response.should be_success
      }.to_not change{inc.reload.status}
    end

    it "should not succeed when the incident is closed" do
      inc.update_attribute :status, 'closed'
      expect {
        post :mark_invalid, id: inc.to_param, chapter_id: inc.chapter.to_param, incidents_incident: {incident_type: 'duplicate', narrative: 'Test'}
        response.should redirect_to("/incidents/#{inc.chapter.to_param}/incidents/needs_report")
        flash[:error].should_not be_empty
      }.to_not change{inc.reload.status}
    end

    it "should trigger the invalid notification" do
      Incidents::Notifications::Notification.should_receive(:create_for_event).with(anything, 'incident_invalid')
      post :mark_invalid, id: inc.to_param, chapter_id: inc.chapter.to_param, incidents_incident: {incident_type: 'invalid', narrative: 'Test'}
    end
  end

  describe "#close" do
    before(:each) { grant_role! 'submit_incident_report' }
    let(:raw_incident) {FactoryGirl.create :raw_incident, chapter: @person.chapter}
    let(:complete_incident) {FactoryGirl.create :closed_incident, chapter: @person.chapter, status: 'open'}

    it "should succeed with a complete incident" do
      expect {
        post :close, id: complete_incident.to_param, chapter_id: complete_incident.chapter.to_param
        response.should redirect_to("/incidents/#{complete_incident.chapter.to_param}/incidents/#{complete_incident.to_param}")
      }.to change{complete_incident.reload.status}.to('closed')
    end

    it "should not succeed with an incomplete incident" do
      expect {
        post :close, id: raw_incident.to_param, chapter_id: raw_incident.chapter.to_param
        response.should redirect_to("/incidents/#{raw_incident.chapter.to_param}/incidents/#{raw_incident.to_param}/dat/edit?status=closed")
      }.to_not change{raw_incident.reload.status}
    end
  end

  describe "#reopen" do
    before(:each) { grant_role! 'create_incident' }
    let(:complete_incident) {FactoryGirl.create :closed_incident, chapter: @person.chapter}

    it "should succeed" do
      expect {
        post :reopen, id: complete_incident.to_param, chapter_id: complete_incident.chapter.to_param
        response.should redirect_to("/incidents/#{complete_incident.chapter.to_param}/incidents/#{complete_incident.to_param}")
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
    before(:each) { Incidents::Notifications::Notification.stub :create_for_event }

    it "should succeed with valid params in editable mode" do
      @person.chapter.update_attributes incidents_report_editable: true
      expect {
        post :create, incidents_incident: params, chapter_id: @person.chapter.to_param
        response.should redirect_to("/incidents/#{@person.chapter.to_param}/incidents/#{params[:incident_number]}")
      }.to change(Incidents::Incident, :count).by(1)
    end

    it "should trigger the created notification" do
      Incidents::Notifications::Notification.should_receive(:create_for_event).with(anything, 'new_incident')
      post :create, incidents_incident: params, chapter_id: @person.chapter.to_param
    end

    it "should succeed with valid params in normal mode" do
      expect {
        post :create, incidents_incident: params, chapter_id: @person.chapter.to_param
        response.should redirect_to("/incidents/#{@person.chapter.to_param}/incidents/#{params[:incident_number]}/dat/new")
      }.to change(Incidents::Incident, :count).by(1)
    end

    describe "with incident number sequence" do

      before(:each) do
         @person.chapter.update_attributes incidents_sequence_enabled: true, 
                                         incidents_sequence_number: 333,
                                         incidents_sequence_format: '%<fy>04d-%<number>03d', 
                                         incidents_sequence_year: FiscalYear.current.year
        params.delete :incident_number
      end

      it "should succeed with valid params with sequence number generator" do
        expect {
          post :create, incidents_incident: params, chapter_id: @person.chapter.to_param
        }.to(change(Incidents::Incident, :count).by(1))
        inc = Incidents::Incident.last
        inc.incident_number.should == "#{FiscalYear.current.year}-334"
        @person.chapter.reload.incidents_sequence_number.should == 334
      end

      it "should not change incident sequence if the create is rejected" do
        params.delete :area_id

        expect {
          expect {
            post :create, incidents_incident: params, chapter_id: @person.chapter.to_param
            response.should be_success # Re-renders the create page rather than redirecting to the incident
          }.to_not(change(Incidents::Incident, :count))
        }.to_not(change{@person.chapter.reload.incidents_sequence_number})
      end

    end

  end

  describe '#activity' do
    before(:each) { grant_role! 'cas_details'; PaperTrail.whodunnit = @person.id }

    it "should succeed" do
      get :activity, chapter_id: @person.chapter.to_param
      response.should be_success
    end

  end

  describe '#resource_changes', versioning: true do
    before(:each) { PaperTrail.whodunnit = @person.id }
    before(:each) { grant_role! 'cas_details'; PaperTrail.whodunnit = @person.id }

    it "should provide list of changes to incidents" do
      i = FactoryGirl.create :incident, chapter: @person.chapter
      i.update_attributes narrative: 'test'
      i.versions.should_not be_blank

      get :activity, {chapter_id: i.chapter.to_param}
      
      controller.resource_changes.should =~ i.versions
      controller.resource_change_people.keys.should =~ [@person.id]
    end

    it "should not list changes for other chapters" do
      chapter = FactoryGirl.create :chapter
      i = FactoryGirl.create :incident, chapter: chapter
      i.update_attributes narrative: 'test'
      i.versions.should_not be_blank
      
      controller.resource_changes.should =~ []
    end

    it "should show only the changes for the given incident if specified" do
      i3 = FactoryGirl.create :incident, chapter: @person.chapter
      i3.update_attributes narrative: 'test123'

      i = FactoryGirl.create :incident, chapter: @person.chapter
      i.update_attributes narrative: 'test'
      i.versions.should_not be_blank

      get :show, {id: i.to_param, chapter_id: i.chapter.to_param}
      
      controller.resource_changes.should =~ i.versions
      controller.resource_change_people.keys.should =~ [@person.id]
    end
  end

end
