require 'spec_helper'

describe "Flex Schedule Page", :type => :feature do
  it "Sets a flex sechedule to Yes" do
    visit "/scheduler/flex_schedules/#{@person.id}"

    find("#scheduler_flex_schedule_available_sunday_day").click
    find(".form-control").select("Yes")
    find(".glyphicon-ok").find(:xpath, ".//..").click

    find("#scheduler_flex_schedule_available_wednesday_night").click
    find(".form-control").select("Yes")
    find(".glyphicon-remove").find(:xpath, ".//..").click

    find("#scheduler_flex_schedule_available_thursday_night").click
    find(".form-control").select("Yes")
    find(".glyphicon-ok").find(:xpath, ".//..").click

    page.should have_text("Yes", count: 2)
    page.should have_text("No", count: 12)

    visit "/scheduler/"
    find(".flex-small").should have_text("Yes", count: 2)
    find(".flex-small").should have_text("No", count: 12)
  end

  it "Sets a flex sechedule to back to No" do
    visit "/scheduler/flex_schedules/#{@person.id}"
    find("#scheduler_flex_schedule_available_sunday_day").click
    find(".form-control").select("Yes")
    find(".glyphicon-ok").find(:xpath, ".//..").click

    # This forces the page to finish doing it's ajax thing
    page.should have_text("Yes", count: 1)
    page.should have_text("No", count: 13)

    visit "/scheduler/flex_schedules/#{@person.id}"
    find("#scheduler_flex_schedule_available_sunday_day").click
    find(".form-control").select("No")
    find(".glyphicon-ok").find(:xpath, ".//..").click

    page.should have_text("Yes", count: 0)
    page.should have_text("No", count: 14)

    visit "/scheduler/"
    find(".flex-small").should have_text("Yes", count: 0)
    find(".flex-small").should have_text("No", count: 14)
  end
end
