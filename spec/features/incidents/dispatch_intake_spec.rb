require 'spec_helper'

describe "Incident Dispatch Intake Console", :type => :feature do

  after :each do
    ActionMailer::Base.deliveries.clear
  end

  before do

    grant_role! :incidents_admin
    @chapter = @person.chapter
    @chapter.incidents_enable_dispatch_console = true
    @chapter.incident_number_sequence = FactoryGirl.create :incident_number_sequence
    @chapter.save!


    @scope = FactoryGirl.create :incidents_scope, enable_dispatch_console: true, chapter: @chapter

    backup_person = FactoryGirl.create :person, chapter: @chapter
    dc = FactoryGirl.create :scheduler_dispatch_config, chapter: @chapter, backup_first: backup_person
    @terr = FactoryGirl.create :territory, chapter: @chapter, dispatch_config: dc, counties: ["San Francisco, CA"]

  end

  def intake_url
    "/incidents/#{@scope.url_slug}/dispatch_intake/new"
  end

  it "handles a referral" do
    visit intake_url

    choose "No"

    page.should have_text "This line is for local emergencies and disaster incidents only"

    fill_in "incidents_call_log[address_entry]", with: "1663 Market St San Francisco\n"

    page.should have_text "The local Red Cross number for San Francisco County is #{@terr.non_disaster_number} ."

    within ".dispatch-region-name" do
      page.should have_text @chapter.name
    end

    within ".dispatch-territory-name" do
      page.should have_text @terr.name
    end

    fill_in "incidents_call_log[referral_reason]", with: Faker::Lorem.paragraph

    click_on "Save Log"

    page.should have_text "Disaster Dispatch"

    log = Incidents::CallLog.last!
    expect(log.call_type).to eq "referral"
    expect(log.referral_reason).to_not be_blank
    expect(log.chapter_id).to eq @chapter.id
  end

  it "handles an incident in territory" do
    visit intake_url
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

    page.should have_text "A Red Cross responder should return your call"

    log = Incidents::CallLog.last!
    expect(log.call_type).to eq "incident"
    expect(log.chapter_id).to eq @chapter.id

    expect(log.incident).to_not be_nil
    expect(log.incident.chapter).to eq @chapter

    page.should have_text log.incident.incident_number
  end

  it "handles invalid input to an incident" do
    visit intake_url
    choose 'Yes'
    page.should have_text "What is the address of the incident?"
    fill_in "incidents_call_log[address_entry]", with: "1663 Market St San Francisco\n"
    page.should have_text "To confirm, that's located in San Francisco county?"
    click_on "Create Incident"

    page.should have_text "can't be blank"
    page.should have_text "To confirm, that's located in San Francisco county?"

    fill_in "May I have the name of the person you would like to have us call back and confirm an estimated time of arrival?", with: Faker::Name.name
    fill_in "The callback phone number for this person?", with: Faker::PhoneNumber.phone_number
    select "Flood", from: "What type of incident is this?*"
    fill_in "Approximately how many people are displaced?", with: "Some"
    fill_in "Are there any special instructions or specific services you are requesting?", with: Faker::Lorem.paragraph
    click_on "Create Incident"

    page.should have_text "A Red Cross responder should return your call"
  end


  it "handles an incident in an unknown territory" do
    visit intake_url
    choose 'Yes'
    page.should have_text "What is the address of the incident?"
    fill_in "incidents_call_log[address_entry]", with: "Oakland, CA\n"
    page.should have_text "To confirm, that's located in Alameda county?"

    page.should have_text "You'll need to call 855-891-7325 to request Red Cross services"
    page.should_not have_text "Create Incident"
  end

  it "handles an incident in an unauthorized territory" do
    @other_terr = FactoryGirl.create :territory, counties: ["Alameda, CA"]

    visit intake_url
    choose 'Yes'
    page.should have_text "What is the address of the incident?"
    fill_in "incidents_call_log[address_entry]", with: "Oakland, CA\n"
    page.should have_text "To confirm, that's located in Alameda county?"

    page.should have_text "You'll need to call #{@other_terr.dispatch_number} to request Red Cross services"
    page.should_not have_text "Create Incident"
  end


end