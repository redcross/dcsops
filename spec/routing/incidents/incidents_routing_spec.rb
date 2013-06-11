require "spec_helper"

describe Incidents::IncidentsController do
  describe "routing" do

    #it "routes to #index" do
    #  get("/incidents/incidents").should route_to("incidents/incidents#index")
    #end

    it "routes to #show" do
      get("/incidents/incidents/15-555").should route_to("incidents/incidents#show", :id => "15-555")
    end

    it "routes to #link_cas" do
      get("/incidents/incidents/link_cas").should route_to("incidents/incidents#link_cas")
      post("/incidents/incidents/link_cas").should route_to("incidents/incidents#link_cas")
    end

    it "routes to #needs_report" do
      get("/incidents/incidents/needs_report").should route_to("incidents/incidents#needs_report")
    end

    #it "routes to #edit" do
    #  get("/incidents/incidents/1/edit").should route_to("incidents/incidents#edit", :id => "1")
    #end
#
    #it "routes to #create" do
    #  post("/incidents/incidents").should route_to("incidents/incidents#create")
    #end
#
    #it "routes to #update" do
    #  put("/incidents/incidents/1").should route_to("incidents/incidents#update", :id => "1")
    #end
#
    #it "routes to #destroy" do
    #  delete("/incidents/incidents/1").should route_to("incidents/incidents#destroy", :id => "1")
    #end

  end
end
