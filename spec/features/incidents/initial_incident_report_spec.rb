require 'spec_helper'

describe "Initial Incident Report", :type => :feature do

  before :each do
    @region = @person.region
    @region.incidents_report_editable = true
    @region.save!
    FactoryGirl.create :incidents_scope, region: @person.region

    @incident = FactoryGirl.create :raw_incident, region: @person.region, area: @person.counties.first, date: Date.current, narrative: 'Blah'
  end

  it "Should be editable" do
    grant_role! :submit_incident_report
    visit "/incidents/#{@region.url_slug}/incidents/#{@incident.incident_number}"

    click_link "IIR"
    
    expect(page).to have_text("Initial Incident Report")
    expect(page).to_not have_css('.btn', text: "Approve")

    click_on 'Incident Type:'
    select 'Hazmat', from: 'Incident type*'
    click_on 'Update Incident'

    expect(page).to have_text('Hazmat')

    click_on 'Estimated # homes affected:'
    expect(page).to have_text('Edit Initial Incident Report')
    check 'Budget is estimated to exceed $10,000'
    select 'Holding Steady', from: 'Trend'
    check 'A shelter is, or will be, opened or put on standby'
    fill_in 'Estimated units', with: '20'
    fill_in 'Estimated individuals', with: '50'
    check 'Shelter'
    check 'Casework'
    check 'The event has significant media coverage'
    check 'Safety concerns'
    click_on 'Initial incident report', exact: false # Create or Update
    expect(page).to_not have_text('Edit Initial Incident Report')
    expect(page).to have_text @person.full_name # Completed by

    iir = @incident.reload.initial_incident_report
    expect(iir).to_not be_nil
    expect(iir.estimated_units).to eq 20
    expect(iir.expected_services).to eq ['shelter', 'casework']
    expect(iir.triggers).to eq ['shelter']
  end

  it "Should be approvable and unapprovable" do
    grant_role! :approve_iir

    iir = FactoryGirl.create :complete_initial_incident_report, incident: @incident
    @incident.event_logs.create event_time: Time.current, event: 'incident_occurred'
    @incident.event_logs.create event_time: Time.current, event: 'dat_received'
    expect(Incidents::PrepareIirJob).to receive(:enqueue).with(iir)

    visit "/incidents/#{@region.url_slug}/incidents/#{@incident.incident_number}"

    click_link "IIR"
    
    expect(page).to have_text("Initial Incident Report")
    expect(page).to have_css('.btn', text: "Approve")

    click_on 'Approve'

    within 'div#edit-modal' do
      expect(page).to have_text("Approve Initial Incident Report")
      click_on 'Approve'
    end

    expect(page).to have_css('.btn', text: "Unapprove")

    iir.reload
    expect(iir.approved_by_id).to_not be_nil

    click_on 'Unapprove'
    expect(page).to have_css('.btn', text: "Approve")
    expect(iir.reload.approved_by_id).to be_nil
  end
  
end