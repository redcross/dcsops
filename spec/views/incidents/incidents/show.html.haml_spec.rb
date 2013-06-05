require 'spec_helper'

describe "incidents/incidents/show" do
  before(:each) do
    @incidents_incident = assign(:incidents_incident, stub_model(Incidents::Incident,
      :chapter => nil,
      :county => nil,
      :incident_number => "Incident Number",
      :cas_incident_number => "Cas Incident Number",
      :city => "City",
      :units_affected => 1,
      :num_adults => 2,
      :num_children => 3,
      :num_families => 4,
      :num_cases => 5,
      :incident_type => "Incident Type",
      :incident_description => "Incident Description",
      :narrative_brief => "MyText",
      :narrative => "MyText"
    ))
  end

  it "renders attributes in <p>" do
    render
    # Run the generator again with the --webrat flag if you want to use webrat matchers
    rendered.should match(//)
    rendered.should match(//)
    rendered.should match(/Incident Number/)
    rendered.should match(/Cas Incident Number/)
    rendered.should match(/City/)
    rendered.should match(/1/)
    rendered.should match(/2/)
    rendered.should match(/3/)
    rendered.should match(/4/)
    rendered.should match(/5/)
    rendered.should match(/Incident Type/)
    rendered.should match(/Incident Description/)
    rendered.should match(/MyText/)
    rendered.should match(/MyText/)
  end
end
