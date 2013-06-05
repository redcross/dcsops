require 'spec_helper'

describe "Incidents::Incidents" do
  describe "GET /incidents_incidents" do
    it "works! (now write some real specs)" do
      # Run the generator again with the --webrat flag if you want to use webrat methods/matchers
      get incidents_incidents_path
      response.status.should be(200)
    end
  end
end
