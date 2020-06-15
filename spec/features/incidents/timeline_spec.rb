require 'spec_helper'

describe "View Timeline", :type => :feature do

  it "Should be submittable" do
    grant_role! :incidents_admin
    @region = @person.region
    @region.incidents_use_global_log = true
    @region.save!
    FactoryGirl.create :incidents_scope, region: @person.region

    @incident = FactoryGirl.create :raw_incident, region: @person.region, shift_territory: @person.shift_territories.first, date: Date.current
    @log = FactoryGirl.create :event_log, region: @region, person: @person, incident: @incident

    visit "/incidents/#{@region.url_slug}/incidents/#{@incident.incident_number}"

    click_link "Timeline"
    
    expect(page).to have_text(@log.message)

    @new_log = FactoryGirl.attributes_for :event_log
    click_button "Add Log"
    select 'Note', from: 'Event*'
    fill_in 'Message', with: @new_log[:message]

    click_button "Create Event log"

    expect(page).not_to have_text("Add Event")
    expect(page).to have_text(@new_log[:message])

    latest_log = Incidents::EventLog.last
    expect(latest_log.message).to eq(@new_log[:message])
  end
  
end