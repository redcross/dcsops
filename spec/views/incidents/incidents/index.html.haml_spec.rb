require 'spec_helper'

describe "incidents/incidents/index" do
  before(:each) do
    assign(:incidents_incidents, [
      stub_model(Incidents::Incident,
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
      ),
      stub_model(Incidents::Incident,
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
      )
    ])
  end

  it "renders a list of incidents/incidents" do
    render
    # Run the generator again with the --webrat flag if you want to use webrat matchers
    assert_select "tr>td", :text => nil.to_s, :count => 2
    assert_select "tr>td", :text => nil.to_s, :count => 2
    assert_select "tr>td", :text => "Incident Number".to_s, :count => 2
    assert_select "tr>td", :text => "Cas Incident Number".to_s, :count => 2
    assert_select "tr>td", :text => "City".to_s, :count => 2
    assert_select "tr>td", :text => 1.to_s, :count => 2
    assert_select "tr>td", :text => 2.to_s, :count => 2
    assert_select "tr>td", :text => 3.to_s, :count => 2
    assert_select "tr>td", :text => 4.to_s, :count => 2
    assert_select "tr>td", :text => 5.to_s, :count => 2
    assert_select "tr>td", :text => "Incident Type".to_s, :count => 2
    assert_select "tr>td", :text => "Incident Description".to_s, :count => 2
    assert_select "tr>td", :text => "MyText".to_s, :count => 2
    assert_select "tr>td", :text => "MyText".to_s, :count => 2
  end
end
