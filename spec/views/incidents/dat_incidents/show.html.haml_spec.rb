require 'spec_helper'

describe "incidents/dat_incidents/show" do
  before(:each) do
    @incidents_dat_incident = assign(:incidents_dat_incident, stub_model(Incidents::DatIncident))
  end

  it "renders attributes in <p>" do
    render
    # Run the generator again with the --webrat flag if you want to use webrat matchers
  end
end
