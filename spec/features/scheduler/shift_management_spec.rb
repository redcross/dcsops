require 'spec_helper'

describe "Shift Scheduler Spec", :type => :feature do
  before :each do
    grant_role! "region_dat_admin"

    group = FactoryGirl.create :shift_time, region: @person.region, start_offset: 10.hours, end_offset: 22.hours
    shift_territory = FactoryGirl.create :shift_territory, name: "Shift Territory", region: @person.region
    position = FactoryGirl.create :position, name: "Position", region: @person.region
    category = FactoryGirl.create :shift_category, name: "Category", region: @person.region

    @shift = FactoryGirl.create :shift,
      shift_times: [group],
      name: "Shift",
      positions: [position],
      shift_category: category,
      shift_territory: shift_territory
  end

  it "Visits this months schedule" do
    visit "/scheduler/"
    click_on "Manage Calendars"
    page.should have_text "Open Shifts"
  end

  it "updates a shift max advance signup" do
    visit "/scheduler/shifts/"

    fill_in "shifts_#{@shift.id}_max_advance_signup", with: 2
    click_on "Save"

    # Force the refresh
    visit "/scheduler/shifts/"

    @shift.reload
    expect(@shift.max_advance_signup).to eq 2
  end
end
