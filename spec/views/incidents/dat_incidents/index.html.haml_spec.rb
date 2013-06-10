require 'spec_helper'

describe "incidents/dat_incidents/index" do
  before(:each) do
    assign(:incidents_dat_incidents, [
      stub_model(Incidents::DatIncident),
      stub_model(Incidents::DatIncident)
    ])
  end

  it "renders a list of incidents/dat_incidents" do
    render
    # Run the generator again with the --webrat flag if you want to use webrat matchers
  end
end
