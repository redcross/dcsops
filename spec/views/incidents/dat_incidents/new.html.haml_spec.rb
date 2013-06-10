require 'spec_helper'

describe "incidents/dat_incidents/new" do
  before(:each) do
    assign(:incidents_dat_incident, stub_model(Incidents::DatIncident).as_new_record)
  end

  it "renders new incidents_dat_incident form" do
    render

    # Run the generator again with the --webrat flag if you want to use webrat matchers
    assert_select "form[action=?][method=?]", incidents_dat_incidents_path, "post" do
    end
  end
end
