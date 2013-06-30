require 'spec_helper'

describe "DAT Incident Report" do
  #self.use_transactional_fixtures = false

  it "Should be submittable" do
    grant_role! 'submit_incident_report'

    @chapter = @person.chapter

    @team_lead = FactoryGirl.create :person, chapter: @person.chapter, counties: @person.counties
    @responder = FactoryGirl.create :person, chapter: @person.chapter, counties: @person.counties
    @flex_responder = FactoryGirl.create :person, chapter: @person.chapter, counties: @person.counties

    @vehicle = FactoryGirl.create :vehicle, chapter: @chapter

    FactoryGirl.create :flex_schedule, person: @flex_responder

    @incident = FactoryGirl.create :incident, chapter: @person.chapter, county: @person.counties.first

    navigate_to_incident
    #visit "/incidents/incidents/#{@incident.incident_number}/dat/new"

    fill_in_details

    click_link "Go to Responders Page"

    fill_in_responders

    click_link "Go to Services Page"

    fill_in_services

    click_button 'Submit Incident Information'

    click_link "Details"
    page.should have_text 'DAT Details'
    page.should have_text 'Demographics'

    @incident.reload.dat_incident.should_not be_nil
    @incident.all_responder_assignments.should have(3).items
    @incident.all_responder_assignments.map(&:person).should =~ [@team_lead, @responder, @flex_responder]

    @incident.address.should == "1663 Market Street"

  end

  def navigate_to_incident
    visit "/incidents"

    click_link "Submit Incident Report"
    within :xpath, "//td[text()='#{@incident.incident_number}']/ancestor::tr" do
      click_link "Submit Incident Information"
    end
  end

  def fill_in_details

    select 'Flood', from: 'Incident type*'
    select 'Cold', from: 'Incident call type*'

    fill_in 'Num adults*', with: 1
    fill_in 'Num children*', with: 1
    fill_in 'Num families*', with: 1
    fill_in 'Num people injured*', with: 1
    fill_in 'Num people hospitalized*', with: 1
    fill_in 'Num people deceased*', with: 1

    fill_in 'Search for address', with: '1663 Market St San Francisco'
    click_button 'Look Up Address'

    select 'Apartment', from: 'Structure type*'
    fill_in 'Units affected*', with: 1
    fill_in 'Units minor*', with: 1
    fill_in 'Units major*', with: 1
    fill_in 'Units destroyed*', with: 1

    # Need the times here
  end

  def fill_in_responders
    fill_in 'incidents_dat_incident_incident_attributes_team_lead_attributes_person_id_text', with: @team_lead.first_name
    click_link @team_lead.full_name

    # Add the flex person
    within :xpath, "//td[text()='#{@flex_responder.full_name}']/.." do
      click_link "Add Responder"
    end

    within "#responder-table tbody" do
      within :xpath, "//input[@value='#{@flex_responder.full_name}']/ancestor::tr" do
        find(:xpath, ".//input[@type='checkbox']").should be_checked
        select 'Responder'
      end
    end

    # Add the regular person
    click_link "Add Other Responder"
    within "#responder-table tbody" do
      within "tr:last-child" do
        fill_in 'person_text', with: @responder.first_name
        click_link @responder.full_name

        find(:xpath, ".//input[@type='checkbox']").should_not be_checked
        select 'Trainee Lead'
      end
    end
  end

  def fill_in_services
    fill_in 'Narrative:', with: 'This is my narrative'
    check 'Food'
    check 'Translation'
    check 'Spanish'

    check 'Meal provided'
    fill_in 'Meal meals', with: 100
    fill_in 'Meal vendor', with: 'McDonalds'

    click_button 'Yes'
    fill_in 'Evac facility name', with: 'Bill Graham'

    click_button 'Shelter Opened'
    fill_in 'Shelter facility name', with: 'YMCA'

    fill_in 'Comfort kits used*', with: 10
    fill_in 'Blankets used*', with: 20

    select @vehicle.name
    click_button 'Add Vehicle'
  end
end