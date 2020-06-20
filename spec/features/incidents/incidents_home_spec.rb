require 'spec_helper'

describe "View Incidents Home Page", :type => :feature do

  before :each do
    FactoryGirl.create :incidents_scope, region: @person.region
  end

  it "Should be viewable" do
    visit "/"

    within(".app", text: "Incidents") do
      click_on "Incidents"
    end

    expect(page).to have_current_path("/incidents/#{@person.region.url_slug}")
  end

  it "Should have recent incidents" do
    5.times { FactoryGirl.create :incident, date: Date.yesterday, region: @person.region, city: "Test City" }
    visit "/incidents/#{@person.region.url_slug}"

    page.should have_text("Test City", count: 5)
  end

  # Tests Issue #143
  it "Should have address in recent incidents" do
    FactoryGirl.create :incident, date: Date.yesterday, region: @person.region, address: "Test Address"
    visit "/incidents/#{@person.region.url_slug}"
    page.should have_text("Test Address")
  end
end
