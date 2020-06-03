require 'spec_helper'

describe "Responder History", :type => :feature do
  it "Should be viewable should not be viewable with someone without permissions" do
    FactoryGirl.create :incidents_scope, chapter: @person.chapter

    visit "/incidents/#{@person.chapter.url_slug}/responses"

    page.should have_text ("You are not authorized to access this page.")

    visit "/"
  end

  it "Should be viewable for someone with permissions" do
    grant_role! 'see_responses'
    FactoryGirl.create :incidents_scope, chapter: @person.chapter

    visit "/incidents/#{@person.chapter.url_slug}"
    click_on "Responder History"
  end

  it "Should have responders" do
    grant_role! 'see_responses'
    incident = FactoryGirl.create :incident, chapter: @person.chapter, date: Date.current
    FactoryGirl.create :responder_assignment, person: @person, incident: incident

    visit "/incidents/#{@person.chapter.url_slug}/responses"

    page.should have_text @person.full_name
  end
end