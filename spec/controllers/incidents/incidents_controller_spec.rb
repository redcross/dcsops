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
      cas = FactoryGirl.create :cas_incident
      cas2 = FactoryGirl.create :cas_incident
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
    it "should succeed with no cas or dat" do
      inc = FactoryGirl.create :incident, chapter: @person.chapter
      get :show, id: inc.to_param
      response.should be_success
    end

    it "should succeed with cas" do
      inc = FactoryGirl.create :incident, chapter: @person.chapter
      cas = FactoryGirl.create :cas_incident
      inc.link_to_cas_incident cas

      get :show, id: inc.to_param
      response.should be_success
    end

    it "should succeed with dat" do
      inc = FactoryGirl.create :incident, chapter: @person.chapter
      dat = FactoryGirl.create :dat_incident, incident: inc
      get :show, id: inc.to_param
      response.should be_success
    end
  end

end
