require 'spec_helper'

describe "Incidents List", :type => :feature do
  it "Should be viewable" do
    FactoryGirl.create :incidents_scope, region: @person.region
    visit "/incidents/#{@person.region.url_slug}"
    click_on "More Incidents"

    page.should have_text "Listing 0 Incidents"
  end
end
