require 'spec_helper'

describe "Manually create incident" do

  it "Should be submittable" do
    grant_role! :submit_incident_report
    grant_role! :incidents_admin
    FactoryGirl.create :incidents_scope, chapter: @person.chapter

    visit "/incidents/#{@person.chapter.url_slug}"

    @incident_number = FactoryGirl.build(:incident).incident_number

    click_link "Submit Incident Report"
    click_link 'Create New Incident'

    select @person.counties.first.name, from: 'Area*'
    fill_in 'Incident number*', with: @incident_number
    select '2013'
    select Date.today.strftime("%B")
    select Date.today.day.to_s

    click_button 'Create Incident'

    page.should have_text('New DAT Incident Report')
  end
  
end