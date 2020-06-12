require 'spec_helper'

describe "Invalid Incident Report", :type => :feature do
  self.use_transactional_tests = false
  before do
    grant_capability! 'submit_incident_report'

    @region = @person.region
    @region.incidents_report_editable = true
    @region.save!
    FactoryGirl.create :incidents_scope, region: @person.region
  end

  it "Should be submittable" do

    @incident = FactoryGirl.create :raw_incident, region: @person.region, shift_territory: @person.shift_territories.first, date: Date.current

    visit "/incidents/#{@region.url_slug}/incidents/#{@incident.incident_number}"

    open_panel "Narrative"
    fill_in 'Narrative*', with: Faker::Lorem.paragraph
    click_button "Update Incident"

    open_panel "Damage Assessment"
    select 'Apartment', from: 'Structure type*'
    fill_in 'Units affected*', with: 1
    fill_in 'Units minor*', with: 1
    fill_in 'Units major*', with: 1
    fill_in 'Units destroyed*', with: 1
    click_button "Update Incident"

    open_panel "Demographics"
    fill_in 'Num adults*', with: 1
    fill_in 'Num children*', with: 1
    fill_in 'Num families*', with: 1
    fill_in 'Num people injured*', with: 1
    fill_in 'Num people hospitalized*', with: 1
    fill_in 'Num people deceased*', with: 1
    click_button "Update Incident"

  end

  def open_panel title
    within "h4", text: title do
      click_link "(edit)"
    end
  end
end
