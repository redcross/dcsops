require 'spec_helper'

describe Incidents::CasLinkController, :type => :controller do
  include LoggedIn
  before(:each) { grant_capability! 'cas_admin' }
  render_views

  it "displays the list" do
    cas = FactoryGirl.create :cas_incident, region: @person.region, county: @person.shift_territories.first.name
    cas2 = FactoryGirl.create :cas_incident, region: @person.region
    inc = FactoryGirl.create :incident, region: @person.region
    inc2 = FactoryGirl.create :incident, region: @person.region

    inc.link_to_cas_incident(cas2)

    get :index, params: { region_id: inc.region.to_param }

    expect(response).to be_successful
    expect(controller.send(:collection)).to match_array([cas])
  end

  it "can link an incident" do
    cas = FactoryGirl.create :cas_incident, region: @person.region
    inc = FactoryGirl.create :incident, region: @person.region

    post :link, params: { id: cas.to_param, incident_id: inc.id, region_id: inc.region.to_param }
    expect(response).to be_redirect
    expect(flash[:info]).not_to be_empty

    expect(inc.reload.cas_event_number).to eq(cas.cas_incident_number)
  end

  it "won't link if the cas is already linked" do
    cas2 = FactoryGirl.create :cas_incident, region: @person.region
    inc = FactoryGirl.create :incident, region: @person.region
    inc2 = FactoryGirl.create :incident, region: @person.region

    inc.link_to_cas_incident(cas2)
    expect {
      post :link, params: { id: cas2.to_param, incident_id: inc2.id, region_id: inc.region.to_param }
      expect(response).to be_redirect
      expect(flash[:error]).not_to be_empty
    }.to_not change{inc.reload.cas_event_number}
  end

  it "can ignore an incident" do
    cas = FactoryGirl.create :cas_incident, region: @person.region

    expect {
      post :ignore, params: { id: cas.to_param, region_id: @person.region.to_param }
    }.to change{cas.reload.ignore_incident}.to(true)

    expect(response).to be_redirect
    expect(flash[:info]).not_to be_empty
  end

  it "can promote to an incident" do
    cas = FactoryGirl.create :cas_incident, region: @person.region
    FactoryGirl.create :shift_territory, name: cas.county, region: @person.region

    expect(Geokit::Geocoders::GoogleGeocoder).to receive(:geocode).and_return(
      double lat: Faker::Address.latitude, lng: Faker::Address.longitude, success?: true, 
             city: Faker::Address.city, district: Faker::Address.city, zip: Faker::Address.zip_code, state: Faker::Address.state)

    expect {
      post :promote, params: { id: cas.to_param, commit: 'Promote to Incident', region_id: cas.region.to_param }
      expect(response).to be_redirect
      expect(flash[:info]).not_to be_empty

    }.to change(Incidents::Incident, :count).by(1)

    expect(Incidents::Incident.where(cas_event_number: cas.cas_incident_number).first).not_to be_nil
  end

end