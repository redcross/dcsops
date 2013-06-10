require "spec_helper"

describe Incidents::DatIncidentsController do
  describe "routing" do

    it "routes to #index" do
      get("/incidents/dat_incidents").should route_to("incidents/dat_incidents#index")
    end

    it "routes to #new" do
      get("/incidents/dat_incidents/new").should route_to("incidents/dat_incidents#new")
    end

    it "routes to #show" do
      get("/incidents/dat_incidents/1").should route_to("incidents/dat_incidents#show", :id => "1")
    end

    it "routes to #edit" do
      get("/incidents/dat_incidents/1/edit").should route_to("incidents/dat_incidents#edit", :id => "1")
    end

    it "routes to #create" do
      post("/incidents/dat_incidents").should route_to("incidents/dat_incidents#create")
    end

    it "routes to #update" do
      put("/incidents/dat_incidents/1").should route_to("incidents/dat_incidents#update", :id => "1")
    end

    it "routes to #destroy" do
      delete("/incidents/dat_incidents/1").should route_to("incidents/dat_incidents#destroy", :id => "1")
    end

  end
end
