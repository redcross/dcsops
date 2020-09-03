require 'spec_helper'

describe "Incident Response Territories Admin Page", :type => :feature do
  before(:each) do
    grant_capability! :region_config
  end

  it "Creates a new Response Territory" do
    visit "/scheduler_admin/response_territories"

    click_on "Create one"

    find("#incidents_response_territory_counties").set("County A")
    all("#incidents_response_territory_counties")[1].set("County B")
    all("#incidents_response_territory_counties")[2].set("County C")
    click_on "Create Response territory"

    find("#incidents_response_territory_region_id").select("Some Region")
    click_on "Create Response territory"

    # This is testing StringArrayInput
    page.should have_text("County A, County B")
  end
end
