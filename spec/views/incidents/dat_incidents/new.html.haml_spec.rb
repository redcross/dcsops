require 'spec_helper'

describe "incidents/dat_incidents/new" do
  has_resource(:dat_incident) {Incidents::DatIncident.new}

  it "should render" do
    view.stub!(:form_url).and_return(incidents_dat_incidents_path)
    view.stub!(:current_user => FactoryGirl.create(:person))
    @dat_incident.completed_by = view.current_user

    render

    # Run the generator again with the --webrat flag if you want to use webrat matchers
    assert_select "form[action=?][method=?]", incidents_dat_incidents_path, "post" do
    end
  end
end
