require 'spec_helper'

describe "Manually create incident", :type => :feature do

  before do
    grant_capability! :submit_incident_report
    grant_capability! :incidents_admin
    FactoryGirl.create :incidents_scope, region: @person.region
    FactoryGirl.create :response_territory, region: @person.region, name: 'SF Response Territory', counties: ['San Francisco, CA']
  end

  it "Should be submittable to dat incident report" do
    visit "/incidents/#{@person.region.url_slug}"

    @incident_number = FactoryGirl.build(:incident).incident_number

    click_on "Submit Incident Report"

    fill_in 'Incident number*', with: @incident_number
    select '2015'
    select Date.today.strftime("%B")
    select Date.today.day.to_s

    select 'Fire', from: 'Incident type*'
    fill_in 'Search for address', with: '1663 market st sf'
    click_on 'Look Up Address'

    # Wait for AJAX to load the response territory
    expect(page).to have_select('Response territory*', selected: 'SF Response Territory')

    click_on 'Create Incident'

    expect(page).to have_text('New DAT Incident Report')
  end

  it "should be submittable with incident number sequence" do
    seq = FactoryGirl.create :incident_number_sequence
    @person.region.update incident_number_sequence: seq, incidents_report_editable: true

    visit "/incidents/#{@person.region.url_slug}/incidents/new"

    expect(page).to_not have_text('Incident number')

    select '2015'
    select Date.today.strftime("%B")
    select Date.today.day.to_s
    select 'Fire', from: 'Incident type*'
    fill_in 'Search for address', with: '1663 market st sf'
    click_on 'Look Up Address'

    # Wait for AJAX to load the response territory
    expect(page).to have_select('Response territory*', selected: 'SF Response Territory')

    click_on 'Create Incident'

    expect(page).to have_text('Response Territory: SF Response Territory')

  end

end