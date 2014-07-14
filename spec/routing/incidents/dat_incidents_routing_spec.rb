require "spec_helper"

describe Incidents::DatIncidentsController, :type => :routing do
  describe "routing" do

    it "routes to #new inside incident" do
      expect(get("/incidents/slug/incidents/15-555/dat/new")).to route_to("incidents/dat_incidents#new", :incident_id => '15-555', :chapter_id => 'slug')
    end

    it "routes to #create" do
      expect(post("/incidents/slug/incidents/15-555/dat")).to route_to("incidents/dat_incidents#create", :incident_id => '15-555', :chapter_id => 'slug')
    end

    it "routes to #update" do
      expect(put("/incidents/slug/incidents/15-555/dat")).to route_to("incidents/dat_incidents#update", :incident_id => '15-555', :chapter_id => 'slug')
    end

  end
end
