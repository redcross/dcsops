require 'spec_helper'

describe "View Incident Report", :type => :feature do
  before do
    FactoryGirl.create :incidents_scope, region: @person.region
  end

  it "Should be viewable" do
    incident = FactoryGirl.create :incident, region: @person.region, date: Date.current
    FactoryGirl.create :dat_incident, incident: incident

    visit "/incidents/#{@person.region.url_slug}/incidents/#{incident.incident_number}"

    # Relating to issue #173
    page.should have_text "Destroyed"
    page.should have_text "Affected"
    page.should have_text "Minor"
    page.should have_text "Major"
    page.should have_text "Livable"
    page.should have_text "Not Livable"
  end

  # Relating to issue #173
  it "Should not have old damage assesments" do
    incident = FactoryGirl.create :incident, region: @person.region, date: Date.current
    FactoryGirl.create :dat_incident, incident: incident,
      units_destroyed: 0,
      units_affected: 0,
      units_minor: 0,
      units_major: 0,
      units_livable: 0,
      units_not_livable: 0

    visit "/incidents/#{@person.region.url_slug}/incidents/#{incident.incident_number}"

    page.should_not have_text "Destroyed"
    page.should_not have_text "Affected"
    page.should_not have_text "Minor"
    page.should_not have_text "Major"
    page.should have_text "Livable"
    page.should have_text "Not Livable"
  end
end
