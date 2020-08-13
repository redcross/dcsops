require 'spec_helper'

describe "Incident Notification Roles Admin Page", :type => :feature do
  before(:each) do
    grant_capability! :region_config
  end

  it "Creates a new Notification Role" do
    visit "/scheduler_admin/notification_roles"

    click_on "Create one"
    fill_in "Name*", with: "A New Notification Role"
    click_on "Add New Role configuration"
    select @person.positions.first.display_name
    select @person.shift_territories.first.display_name
    click_on "Create Role"
    page.should have_text("A New Notification Role")
    # The position above, should have the current @person in it
    page.should have_text(@person.full_name)

    click_on "Notification Roles"
    # Make sure list page fully loads
    expect(page).to have_current_path("/scheduler_admin/notification_roles")
  end
end
