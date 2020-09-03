require 'spec_helper'

describe "Responder History", :type => :feature do
  it "Should be viewable should not be viewable with someone without permissions" do
    FactoryGirl.create :incidents_scope, region: @person.region

    visit "/incidents/#{@person.region.url_slug}/responses"

    page.should have_text ("You are not authorized to access that page.")

    visit "/"
  end

  it "Should be viewable for someone with permissions" do
    grant_capability! 'see_responses'
    FactoryGirl.create :incidents_scope, region: @person.region

    visit "/incidents/#{@person.region.url_slug}"
    click_on "Responder History"
  end

  it "Should have responders" do
    grant_capability! 'see_responses'
    incident = FactoryGirl.create :incident, region: @person.region, date: Date.current
    FactoryGirl.create :responder_assignment, person: @person, incident: incident

    visit "/incidents/#{@person.region.url_slug}/responses"

    page.should have_text @person.full_name
  end
end
