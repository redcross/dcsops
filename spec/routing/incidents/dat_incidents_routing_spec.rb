require "spec_helper"

describe Incidents::DatIncidentsController do
  describe "routing" do

    it "routes to #new inside incident" do
      get("/incidents/incidents/15-555/dat/new").should route_to("incidents/dat_incidents#new", :incident_id => '15-555')
    end

    it "routes to #create" do
      post("/incidents/incidents/15-555/dat").should route_to("incidents/dat_incidents#create", :incident_id => '15-555')
    end

    it "routes to #update" do
      put("/incidents/incidents/15-555/dat").should route_to("incidents/dat_incidents#update", :incident_id => '15-555')
    end

  end
end
