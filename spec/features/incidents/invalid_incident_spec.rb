require 'spec_helper'

describe "Invalid Incident Report" do
  #self.use_transactional_fixtures = false

  it "Should be submittable" do
    grant_role! 'submit_incident_report'

    @chapter = @person.chapter
    @incident = FactoryGirl.create :raw_incident, chapter: @person.chapter, area: @person.counties.first

    visit "/incidents"

    click_link "Submit Incident Report"
    within :xpath, "//td[text()='#{@incident.incident_number}']/ancestor::tr" do
      click_link "Mark Invalid"
    end

    select 'Not Eligible For Services'
    fill_in 'Please Explain*', with: 'A message'

    click_button 'Remove This Incident'

    page.should have_text 'Incidents Needing Incident Report'

    @incident.reload.incident_type.should == 'not_eligible_for_services'
  end
end
