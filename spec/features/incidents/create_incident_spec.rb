require 'spec_helper'

describe "Manually create incident", :type => :feature do

  it "Should be submittable to dat incident report" do
    grant_role! :submit_incident_report
    grant_role! :incidents_admin
    FactoryGirl.create :incidents_scope, chapter: @person.chapter

    visit "/incidents/#{@person.chapter.url_slug}"

    @incident_number = FactoryGirl.build(:incident).incident_number

    click_on "Submit Incident Report"
    click_on 'Create New Incident'

    select @person.counties.first.name, from: 'Area*'
    fill_in 'Incident number*', with: @incident_number
    select '2013'
    select Date.today.strftime("%B")
    select Date.today.day.to_s

    select 'Fire', from: 'Incident type*'
    fill_in 'Search for address', with: '1663 market st sf'
    click_on 'Look Up Address'

    click_on 'Create Incident'

    expect(page).to have_text('New DAT Incident Report')
  end

end