require 'spec_helper'

describe "Notifications Settings Page", :type => :feature do
  it "Views the default page as admin" do
    grant_role! 'region_dat_admin'

    visit "/scheduler/"
    click_on "Update reminder preferences"

    page.should have_text "Reminder Settings"
  end

  it "Uses the me id" do
    visit "/scheduler/notification_settings/me"

    page.should have_text "Reminder Settings"
  end

  it "Updates an option" do
    visit "/scheduler/notification_settings/me"

    click_on "scheduler_notification_setting_send_email_invites"
    find(".form-control").select("Do")
    find(".glyphicon-ok").find(:xpath, ".//..").click

    page.should have_text("Do not", count: 1)
  end
end
