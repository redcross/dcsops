require 'spec_helper'

describe "Invalid Incident Report", :type => :feature do
  #self.use_transactional_tests = false

  it "Should be submittable" do
    grant_role! 'submit_incident_report'

    @chapter = @person.chapter
    FactoryGirl.create :incidents_scope, chapter: @person.chapter
    @incident = FactoryGirl.create :raw_incident, chapter: @person.chapter, area: @person.counties.first

    visit "/incidents/#{@chapter.url_slug}"

    click_link "Submit Incident Report"
    within :xpath, "//td[text()='#{@incident.incident_number}']/ancestor::tr" do
      click_link "Mark Invalid"
    end

    select 'Not Eligible For Services'
    fill_in 'Please Explain*', with: 'A message'

    click_button 'Remove This Incident'

    expect(page).to have_text 'Currently Open Incidents'

    expect(@incident.reload.incident_type).to eq('not_eligible_for_services')
  end
end
