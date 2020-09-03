require 'spec_helper'

# This is here as just a sanity smoke test for basic
# "can I get to the page" tests
describe "Basic Admin Pages", :type => :feature do
  before(:each) do
    grant_capability! :region_config
  end

  it "Visits the Call Logs page" do
    visit "/scheduler_admin/people"
    find("#incidents").hover
    click_on "Call Logs"
    expect(page).to have_current_path("/scheduler_admin/call_logs")
  end

  it "Visits the Deployments page" do
    visit "/scheduler_admin/people"
    find("#incidents").hover
    click_on "Deployments"
    expect(page).to have_current_path("/scheduler_admin/deployments")
  end

  it "Visits the Disasters page" do
    visit "/scheduler_admin/people"
    find("#incidents").hover
    click_on "Disasters"
    expect(page).to have_current_path("/scheduler_admin/disasters")
  end

  it "Visits the Dispatch Logs page" do
    visit "/scheduler_admin/people"
    find("#incidents").hover
    click_on "Dispatch Logs"
    expect(page).to have_current_path("/scheduler_admin/dispatch_logs")
  end

  it "Visits the Events page" do
    visit "/scheduler_admin/people"
    find("#incidents").hover
    click_on "Events"
    expect(page).to have_current_path("/scheduler_admin/events")
  end

  it "Visits the Notification Roles page" do
    visit "/scheduler_admin/people"
    find("#incidents").hover
    click_on "Notification Roles"
    expect(page).to have_current_path("/scheduler_admin/notification_roles")
  end

  it "Visits the Number Sequences page" do
    visit "/scheduler_admin/people"
    find("#incidents").hover
    click_on "Number Sequences"
    expect(page).to have_current_path("/scheduler_admin/number_sequences")
  end

  it "Visits the Price List Items page" do
    visit "/scheduler_admin/people"
    find("#incidents").hover
    click_on "Price List Items"
    expect(page).to have_current_path("/scheduler_admin/price_list_items")
  end

  it "Visits the Report Subscriptions page" do
    visit "/scheduler_admin/people"
    find("#incidents").hover
    click_on "Report Subscriptions"
    expect(page).to have_current_path("/scheduler_admin/report_subscriptions")
  end

  it "Visits the Responder Messages page" do
    visit "/scheduler_admin/people"
    find("#incidents").hover
    click_on "Responder Messages"
    expect(page).to have_current_path("/scheduler_admin/responder_messages")
  end

  it "Visits the Scopes page" do
    visit "/scheduler_admin/people"
    find("#incidents").hover
    click_on "Scopes"
    expect(page).to have_current_path("/scheduler_admin/scopes")
  end

  it "Visits the Response Territories page" do
    visit "/scheduler_admin/people"
    find("#incidents").hover
    click_on "Response Territories"
    expect(page).to have_current_path("/scheduler_admin/response_territories")
  end

  it "Visits the Vehicles page" do
    visit "/scheduler_admin/people"
    find("#logistics").hover
    click_on "Vehicles"
    expect(page).to have_current_path("/scheduler_admin/vehicles")
  end

  it "Visits the Connect Access Tokens page" do
    visit "/scheduler_admin/people"
    find("#openid").hover
    click_on "Connect Access Tokens"
    expect(page).to have_current_path("/scheduler_admin/connect_access_tokens")
  end

  it "Visits the Connect Authorizations page" do
    visit "/scheduler_admin/people"
    find("#openid").hover
    click_on "Connect Authorizations"
    expect(page).to have_current_path("/scheduler_admin/connect_authorizations")
  end

  it "Visits the Connect Clients page" do
    visit "/scheduler_admin/people"
    find("#openid").hover
    click_on "Connect Clients"
    expect(page).to have_current_path("/scheduler_admin/connect_clients")
  end

  it "Visits the Connect Scopes page" do
    visit "/scheduler_admin/people"
    find("#openid").hover
    click_on "Connect Scopes"
    expect(page).to have_current_path("/scheduler_admin/connect_scopes")
  end

  it "Visits the Partners page" do
    visit "/scheduler_admin/people"
    find("#partners.has_nested").hover
    within("#partners.has_nested") do
      find("#partners").click
    end
    expect(page).to have_current_path("/scheduler_admin/partners")
  end

  it "Visits the Cell Carriers page" do
    visit "/scheduler_admin/people"
    find("#roster").hover
    click_on "Cell Carriers"
    expect(page).to have_current_path("/scheduler_admin/cell_carriers")
  end

  it "Visits the Regions page" do
    visit "/scheduler_admin/people"
    find("#roster").hover
    click_on "Regions"
    expect(page).to have_current_path("/scheduler_admin/regions")
  end

  it "Visits the Shift Territories page" do
    visit "/scheduler_admin/people"
    find("#roster").hover
    click_on "Shift Territories"
    expect(page).to have_current_path("/scheduler_admin/shift_territories")
  end

  it "Visits the People page" do
    visit "/scheduler_admin/people"
    find("#roster").hover
    click_on "People"
    expect(page).to have_current_path("/scheduler_admin/people")
  end

  it "Visits the Positions page" do
    visit "/scheduler_admin/people"
    find("#roster").hover
    click_on "Positions"
    expect(page).to have_current_path("/scheduler_admin/positions")
  end

  it "Visits the Region Admin page" do
    visit "/scheduler_admin/people"
    find("#roster").hover
    click_on "Region Admin"
    expect(page).to have_current_path("/scheduler_admin/region_admins")
  end

  it "Visits the Roles page" do
    visit "/scheduler_admin/people"
    find("#roster").hover
    click_on "Capabilities"
    expect(page).to have_current_path("/scheduler_admin/capabilities")
  end

  it "Visits the Dispatch Configs page" do
    visit "/scheduler_admin/people"
    find("#scheduling").hover
    click_on "Dispatch Configs"
    expect(page).to have_current_path("/scheduler_admin/dispatch_configs")
  end

  it "Visits the Shift Categories page" do
    visit "/scheduler_admin/people"
    find("#scheduling").hover
    click_on "Shift Categories"
    expect(page).to have_current_path("/scheduler_admin/shift_categories")
  end

  it "Visits the Shift Times page" do
    visit "/scheduler_admin/people"
    find("#scheduling").hover
    click_on "Shift Times"
    expect(page).to have_current_path("/scheduler_admin/shift_times")
  end

  it "Visits the Shifts page" do
    visit "/scheduler_admin/people"
    find("#scheduling").hover
    click_on "Shifts"
    expect(page).to have_current_path("/scheduler_admin/shifts")
  end

  it "Visits the Data Filters page" do
    visit "/scheduler_admin/people"
    find("#system").hover
    click_on "Data Filters"
    expect(page).to have_current_path("/scheduler_admin/data_filters")
  end

  it "Visits the Homepage Links page" do
    visit "/scheduler_admin/people"
    find("#system").hover
    click_on "Homepage Links"
    expect(page).to have_current_path("/scheduler_admin/homepage_links")
  end

  it "Visits the Jobs page" do
    visit "/scheduler_admin/people"
    find("#system").hover
    click_on "Jobs"
    expect(page).to have_current_path("/scheduler_admin/jobs")
  end

  it "Visits the Lookups page" do
    visit "/scheduler_admin/people"
    find("#system").hover
    click_on "Lookups"
    expect(page).to have_current_path("/scheduler_admin/lookups")
  end

  it "Visits the Mot Ds page" do
    visit "/scheduler_admin/people"
    find("#system").hover
    click_on "Mot Ds"
    expect(page).to have_current_path("/scheduler_admin/motds")
  end

  it "Visits the Named Queries page" do
    visit "/scheduler_admin/people"
    find("#system").hover
    click_on "Named Queries"
    expect(page).to have_current_path("/scheduler_admin/named_queries")
  end
end
