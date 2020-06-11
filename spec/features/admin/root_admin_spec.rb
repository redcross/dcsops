require 'spec_helper'

describe "Root Admin Page", :type => :feature do
  it "Visits the admin page" do
    # Can't visit till enabled
    visit "/"

    page.should_not have_text("Admin")
    grant_role! :region_config

    visit "/"
    click_on "Admin"

    expect(page).to have_current_path("/scheduler_admin/people")
  end
end
