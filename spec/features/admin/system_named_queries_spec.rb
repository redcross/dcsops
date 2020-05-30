require 'spec_helper'

describe "System Named Queries Admin Page", :type => :feature do
  before(:each) do
    grant_role! :chapter_config
  end

  it "Creates a new Homepage Link" do
    visit "/scheduler_admin/named_queries"

    click_on "Create one"
    fill_in "Name", with: "A New Named Query"

    # This controller is used in production, so a fine check to have here
    fill_in "Controller", with: "Roster::PeopleController"

    click_on ("Create Named query")
    page.should have_text("A New Named Query")

    click_on "Named Queries"
    # Make sure list page fully loads
    expect(page).to have_current_path("/scheduler_admin/named_queries")
  end
end
