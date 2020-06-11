require 'spec_helper'

describe "Incident Territories Admin Page", :type => :feature do
  before(:each) do
    grant_role! :region_config
  end

  it "Creates a new Territory" do
    visit "/scheduler_admin/territories"

    click_on "Create one"

    find("#incidents_territory_counties").set("County A")
    all("#incidents_territory_counties")[1].set("County B")
    all("#incidents_territory_counties")[2].set("County C")
    click_on "Create Territory"

    find("#incidents_territory_region_id").select("Some Region")
    click_on "Create Territory"

    # This is testing StringArrayInput
    page.should have_text("\"County A\", \"County B\"")
  end
end
