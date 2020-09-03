require 'spec_helper'

describe "Incident Dispatch Intake Console", :type => :feature do

  after :each do
    ActionMailer::Base.deliveries.clear
  end

  before :each do
    @region = @person.region
    @region.incidents_enable_dispatch_console = true
    @region.incident_number_sequence = FactoryGirl.create :incident_number_sequence
    @region.save!

    # Emulate the production norcen_dispatch link
    @scope = FactoryGirl.create :incidents_scope, enable_dispatch_console: true, region: @region

    grant_capability!(:dispatch_console, [@scope.id])
    grant_capability!(:dispatch_console, [@scope.id])

    backup_person = FactoryGirl.create :person, region: @region
    dc = FactoryGirl.create :scheduler_dispatch_config, region: @region, backup_first: backup_person
    @terr = FactoryGirl.create :response_territory, region: @region, dispatch_config: dc, counties: ["San Francisco, CA"]

  end

  def visit_intake
    visit "/incidents/"
    click_on "Dispatch New Incident"
  end

  it "handles a referral" do
    visit_intake

    choose "No"

    page.should have_text "This line is for local emergencies and disaster incidents only"

    fill_in "incidents_call_log[address_entry]", with: "1663 Market St San Francisco\n"

    page.should have_text "The local Red Cross number for San Francisco County is #{@terr.non_disaster_number} ."

    within ".dispatch-region-name" do
      page.should have_text @region.name
    end

    within ".dispatch-response-territory-name" do
      page.should have_text @terr.name
    end

    fill_in "incidents_call_log[referral_reason]", with: Faker::Lorem.paragraph

    click_on "Save Log"

    page.should have_text "Disaster Dispatch"

    log = Incidents::CallLog.last!
    expect(log.call_type).to eq "referral"
    expect(log.referral_reason).to_not be_blank
    expect(log.region_id).to eq @region.id
  end

  it "handles an incident in response territory" do
    visit_intake
    choose 'Yes'
    page.should have_text "What is the address of the incident?"
    fill_in "incidents_call_log[address_entry]", with: "1663 Market St San Francisco\n"
    page.should have_text "To confirm, that's located in San Francisco county?"
    fill_in "May I have the name of the person you would like to have us call back and confirm an estimated time of arrival?", with: Faker::Name.name
    fill_in "The callback phone number for this person?", with: Faker::PhoneNumber.phone_number
    select "Flood", from: "What type of incident is this?*"
    fill_in "Approximately how many people are displaced?", with: "Some"
    fill_in "Are there any special instructions or specific services you are requesting?", with: Faker::Lorem.paragraph
    click_on "Create Incident"

    page.should have_text "Please immediately alert the Region to this incident so they"

    log = Incidents::CallLog.last!
    expect(log.call_type).to eq "incident"
    expect(log.region_id).to eq @region.id

    expect(log.incident).to_not be_nil
    expect(log.incident.region).to eq @region

    page.should have_text log.incident.incident_number
  end

  it "handles invalid input to an incident" do
    visit_intake
    choose 'Yes'
    page.should have_text "What is the address of the incident?"
    fill_in "incidents_call_log[address_entry]", with: "1663 Market St San Francisco\n"
    page.should have_text "To confirm, that's located in San Francisco county?"
    click_on "Create Incident"

    fill_in "May I have the name of the person you would like to have us call back and confirm an estimated time of arrival?", with: Faker::Name.name
    fill_in "The callback phone number for this person?", with: Faker::PhoneNumber.phone_number
    select "Flood", from: "What type of incident is this?*"
    fill_in "Approximately how many people are displaced?", with: "Some"
    fill_in "Are there any special instructions or specific services you are requesting?", with: Faker::Lorem.paragraph
    click_on "Create Incident"

    page.should have_text "Please immediately alert the Region to this incident so they"
  end


  it "handles an incident in an unknown response territory" do
    visit_intake
    choose 'Yes'
    page.should have_text "What is the address of the incident?"
    fill_in "incidents_call_log[address_entry]", with: "Oakland, CA\n"
    page.should have_text "To confirm, that's located in Alameda county?"

    page.should have_text "You'll need to call 855-891-7325 to request Red Cross services"
    page.should_not have_text "Create Incident"
  end

  it "handles an incident in an unauthorized response territory" do
    @other_terr = FactoryGirl.create :response_territory, counties: ["Alameda, CA"]

    visit_intake
    choose 'Yes'
    page.should have_text "What is the address of the incident?"
    fill_in "incidents_call_log[address_entry]", with: "Oakland, CA\n"
    page.should have_text "To confirm, that's located in Alameda county?"

    page.should have_text "You'll need to call #{@other_terr.dispatch_number} to request Red Cross services"
    page.should_not have_text "Create Incident"
  end


end