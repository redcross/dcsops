require "spec_helper"

describe Incidents::DatIncidentsController do
  describe "routing" do

    it "routes to #new inside incident" do
      get("/incidents/slug/incidents/15-555/dat/new").should route_to("incidents/dat_incidents#new", :incident_id => '15-555', :chapter_id => 'slug')
    end

    it "routes to #create" do
      post("/incidents/slug/incidents/15-555/dat").should route_to("incidents/dat_incidents#create", :incident_id => '15-555', :chapter_id => 'slug')
    end

    it "routes to #update" do
      put("/incidents/slug/incidents/15-555/dat").should route_to("incidents/dat_incidents#update", :incident_id => '15-555', :chapter_id => 'slug')
    end

  end
end
