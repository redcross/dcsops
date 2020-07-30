require 'spec_helper'

describe "Shift Notes Page", :type => :feature do
  before :each do
    grant_capability! 'shift_territory_dat_admin'

    time = FactoryGirl.create :shift_time, region: @person.region, start_offset: 10.hours, end_offset: 22.hours
    shift_territory = FactoryGirl.create :shift_territory, name: "Shift Territory", region: @person.region
    position = FactoryGirl.create :position, name: "Position", region: @person.region
    category = FactoryGirl.create :shift_category, name: "Category", region: @person.region

    shift = FactoryGirl.create :shift,
      shift_times: [time],
      name: "Shift",
      positions: [position],
      shift_category: category,
      shift_territory: shift_territory

    @person.shift_territories = [shift_territory]
    @person.positions = [position]
    @person.save

    @assignment = FactoryGirl.create :shift_assignment,
      shift: shift,
      shift_time: time,
      person: @person,
      date: Time.current.beginning_of_day
  end

  it "visits the page" do
    visit "/scheduler/"
    click_on "Shift Notes"
    page.should have_text(@person.full_name, count: 2)
  end

  it "adds a note" do
    visit "/scheduler/"
    click_on "Shift Notes"

    page.should have_text(@person.full_name, count: 2)

    click_on "scheduler_shift_assignment_note-#{@assignment.id}"

    find(".input-sm").set("Test Note")
    find(".glyphicon-ok").find(:xpath, ".//..").click

    page.should have_text "Test Note"
  end
end
