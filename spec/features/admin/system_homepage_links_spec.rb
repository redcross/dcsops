require 'spec_helper'

describe "System Homepage Links Admin Page", :type => :feature do
  before(:each) do
    grant_role! :region_config
  end

  it "Creates a new Homepage Link" do
    visit "/scheduler_admin/homepage_links"

    click_on "Create one"
    fill_in "Name", with: "A New Homepage Link"
    within first "#homepage_link_submit_action" do
      click_on ("Create Homepage link")
    end
    page.should have_text("A New Homepage Link")

    click_on "Homepage Links"
    # Make sure list page fully loads
    expect(page).to have_current_path("/scheduler_admin/homepage_links")
  end
end
