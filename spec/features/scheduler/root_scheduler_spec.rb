require 'spec_helper'

describe "Root Scheduler Page", :type => :feature do
  it "Visits the scheduler page" do
    visit "/"

    within "div.app", text: "DAT Scheduling" do
      click_on "DAT Scheduling"
    end

    expect(page).to have_current_path("/scheduler")
  end

  it "Views the default page" do
    visit "/scheduler/"

    # This isn't a comprehensive check, but should suffice that the
    # page is actually working.
    page.should have_text "You have completed 0 shifts since the new"
    page.should have_text "You have no upcoming shifts scheduled."

    # Flex schedule should be empty by default
    find(".flex-small").should_not have_text "Yes"
    find(".flex-small").should have_text("No", count: 14)
  end

  it "Views the default page with shifts" do
    shift = FactoryGirl.create :shift, shift_territory: @person.shift_territories.first, positions: @person.positions
    shift_time = shift.shift_times.first
    (1..5).map{|i| Scheduler::ShiftAssignment.create! person:@person, date:Date.today+i, shift:shift, shift_time:shift_time}

    visit "/scheduler/"

    page.should_not have_text "You have no upcoming shifts scheduled."
  end

  it "Views the default page with completed shifts" do
    shift = FactoryGirl.create :shift, shift_territory: @person.shift_territories.first, positions: @person.positions
    shift_time = shift.shift_times.first
    (1..5).map{|i| Scheduler::ShiftAssignment.create! person:@person, date:Date.today-i, shift:shift, shift_time:shift_time}

    visit "/scheduler/"

    page.should have_text "You have completed 5 shifts."
  end
end
