require 'spec_helper'

describe "Invalid Incident Report", :type => :feature do
  #self.use_transactional_tests = false

  it "Should be submittable" do
    grant_capability! 'submit_incident_report'

    @region = @person.region
    FactoryGirl.create :incidents_scope, region: @person.region
    @incident = FactoryGirl.create :raw_incident,
      region: @person.region,
      shift_territory: @person.shift_territories.first,
      city: "Test City",
      date: Date.current

    visit "/incidents/#{@region.url_slug}"

    click_on "Test City"
    click_link "Invalid/No Response"

    select 'Not Eligible For Services'
    fill_in 'Please Explain*', with: 'A message'

    click_button 'Remove This Incident'

    expect(page).to have_text 'Currently Open Incidents'
    expect(@incident.reload.reason_marked_invalid).to eq('not_eligible_for_services')
  end
end
