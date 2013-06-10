require 'spec_helper'

describe "incidents/dat_incidents/edit" do
  before(:each) do
    @incidents_dat_incident = assign(:incidents_dat_incident, stub_model(Incidents::DatIncident))
  end

  it "renders the edit incidents_dat_incident form" do
    render

    # Run the generator again with the --webrat flag if you want to use webrat matchers
    assert_select "form[action=?][method=?]", incidents_dat_incident_path(@incidents_dat_incident), "post" do
    end
  end
end
