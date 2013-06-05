require 'spec_helper'

describe "incidents/incidents/edit" do
  before(:each) do
    @incidents_incident = assign(:incidents_incident, stub_model(Incidents::Incident,
      :chapter => nil,
      :county => nil,
      :incident_number => "MyString",
      :cas_incident_number => "MyString",
      :city => "MyString",
      :units_affected => 1,
      :num_adults => 1,
      :num_children => 1,
      :num_families => 1,
      :num_cases => 1,
      :incident_type => "MyString",
      :incident_description => "MyString",
      :narrative_brief => "MyText",
      :narrative => "MyText"
    ))
  end

  it "renders the edit incidents_incident form" do
    render

    # Run the generator again with the --webrat flag if you want to use webrat matchers
    assert_select "form[action=?][method=?]", incidents_incident_path(@incidents_incident), "post" do
      assert_select "input#incidents_incident_chapter[name=?]", "incidents_incident[chapter]"
      assert_select "input#incidents_incident_county[name=?]", "incidents_incident[county]"
      assert_select "input#incidents_incident_incident_number[name=?]", "incidents_incident[incident_number]"
      assert_select "input#incidents_incident_cas_incident_number[name=?]", "incidents_incident[cas_incident_number]"
      assert_select "input#incidents_incident_city[name=?]", "incidents_incident[city]"
      assert_select "input#incidents_incident_units_affected[name=?]", "incidents_incident[units_affected]"
      assert_select "input#incidents_incident_num_adults[name=?]", "incidents_incident[num_adults]"
      assert_select "input#incidents_incident_num_children[name=?]", "incidents_incident[num_children]"
      assert_select "input#incidents_incident_num_families[name=?]", "incidents_incident[num_families]"
      assert_select "input#incidents_incident_num_cases[name=?]", "incidents_incident[num_cases]"
      assert_select "input#incidents_incident_incident_type[name=?]", "incidents_incident[incident_type]"
      assert_select "input#incidents_incident_incident_description[name=?]", "incidents_incident[incident_description]"
      assert_select "textarea#incidents_incident_narrative_brief[name=?]", "incidents_incident[narrative_brief]"
      assert_select "textarea#incidents_incident_narrative[name=?]", "incidents_incident[narrative]"
    end
  end
end
