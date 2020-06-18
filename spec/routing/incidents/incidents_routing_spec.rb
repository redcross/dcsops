require "spec_helper"

describe Incidents::IncidentsController, :type => :routing do
  describe "routing" do

    #it "routes to #index" do
    #  get("/incidents/incidents").should route_to("incidents/incidents#index")
    #end

    it "routes to #show" do
      expect(get("/incidents/slug/incidents/15-555")).to route_to("incidents/incidents#show", :id => "15-555", region_id: 'slug')
    end

    it "routes to #link_cas" do
      expect(get("/incidents/slug/incidents/link_cas")).to route_to("incidents/incidents#link_cas", region_id: 'slug')
      expect(post("/incidents/slug/incidents/link_cas")).to route_to("incidents/incidents#link_cas", region_id: 'slug')
    end

    it "routes to #needs_report" do
      expect(get("/incidents/slug/incidents/needs_report")).to route_to("incidents/incidents#needs_report", region_id: 'slug')
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
