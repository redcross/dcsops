require 'spec_helper'

describe "Notifications Settings Page", :type => :feature do
  it "Views the default page as admin" do
    grant_role! 'chapter_dat_admin'

    visit "/scheduler/"
    click_on "Show Roster"
  end

  it "Updates last shift taken" do
    grant_role! 'chapter_dat_admin'

    visit "/scheduler/"
    click_on "Show Roster"

    select "1 Week", from: "last_shift"
    click_on "Show"
  end
end
