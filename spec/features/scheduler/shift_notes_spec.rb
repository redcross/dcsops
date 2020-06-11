require 'spec_helper'

# This page isn't linked to from anywhere, as of now, but it's used
# from people who know the URL.  So we should have tests, but they break
# the usual rule of traversing to the page naturally at least once
describe "Shift Notes Page", :type => :feature do
  before :each do
    grant_role! 'county_dat_admin'

    group = FactoryGirl.create :shift_group, chapter: @person.chapter, start_offset: 10.hours, end_offset: 22.hours
    county = FactoryGirl.create :county, name: "County", chapter: @person.chapter
    position = FactoryGirl.create :position, name: "Position", chapter: @person.chapter
    category = FactoryGirl.create :shift_category, name: "Category", chapter: @person.chapter

    shift = FactoryGirl.create :shift,
      shift_groups: [group],
      name: "Shift",
      positions: [position],
      shift_category: category,
      county: county

    @person.counties = [county]
    @person.positions = [position]
    @person.save

    @assignment = FactoryGirl.create :shift_assignment,
      shift: shift,
      shift_group: group,
      person: @person,
      date: Time.current.beginning_of_day
  end

  it "visits the page" do
    visit "/scheduler/shift_notes"
    page.should have_text(@person.full_name, count: 2)
  end

  it "adds a note" do
    visit "/scheduler/shift_notes"

    page.should have_text(@person.full_name, count: 2)

    click_on "scheduler_shift_assignment_note-#{@assignment.id}"

    find(".input-sm").set("Test Note")
    find(".glyphicon-ok").find(:xpath, ".//..").click

    page.should have_text "Test Note"
  end
end
