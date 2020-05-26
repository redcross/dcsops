require 'spec_helper'

describe "Shift Scheduler Spec", :type => :feature do

  def next_month_calendar
    next_month = Date.current.next_month.strftime("%B").downcase
    next_month_year = Date.current.next_month.strftime("%Y")
    "/scheduler/calendar/#{next_month_year}/#{next_month}"
  end

  before :each do
    group = FactoryGirl.create :shift_group, chapter: @person.chapter, start_offset: 10.hours, end_offset: 22.hours
    @counties = (1..2).map{|i| FactoryGirl.create :county, name: "County #{i}", chapter: @person.chapter}
    @positions = (1..2).map{|i| FactoryGirl.create :position, name: "Position #{i}", chapter: @person.chapter}
    @categories = (1..2).map{|i| FactoryGirl.create :shift_category, name: "Category #{i}", chapter: @person.chapter}

    FactoryGirl.create :shift,
      shift_groups: [group],
      name: "Shift 1",
      positions: [@positions.find{|p| p.name == "Position 1"}],
      shift_category: @categories.find{|c| c.name == "Category 1"},
      county: @counties.find{|c| c.name == "County 1"}

    FactoryGirl.create :shift,
      shift_groups: [group],
      name: "Shift 2",
      positions: [@positions.find{|p| p.name == "Position 2"}],
      shift_category: @categories.find{|c| c.name == "Category 2"},
      county: @counties.find{|c| c.name == "County 2"}
  end

  it "Visits this months schedule" do
    visit "/scheduler/"

    next_month = Date.current.next_month.strftime("%B")

    within find("strong", text: next_month).find(:xpath, "./following-sibling::div") do
      click_on "Sign Up"
    end

    page.should have_text("My Positions")
    page.should have_text("County Shifts")
    page.should have_text("Available Shifts")
    page.should have_text(next_month)
  end

  it "Looks at all shifts" do
    visit next_month_calendar
    click_on "All Shifts"

    page.should have_text("OPEN")
    page.should have_text("Shift 1")
  end

  it "Signs up for a shift" do
    @person.positions = @positions[0..0]
    @person.counties = @counties

    visit "/scheduler/"
    page.should have_text "You have no upcoming shifts scheduled."
    page.should have_text "#{Date.current.next_month.end_of_month.day * @person.positions.length} Shifts Available"

    visit next_month_calendar
    page.should have_text "OPEN"
    
    checkbox = first(".shift-checkbox")
    checkbox.click
    page.should have_text "#{@person.first_name[0..0]} #{@person.last_name}"

    visit "/scheduler/"
    page.should_not have_text "You have no upcoming shifts scheduled."
  end

  it "Signs up and removes sign up for a shift" do
    @person.positions = @positions[0..0]
    @person.counties = @counties

    visit next_month_calendar
    
    checkbox = first(".shift-checkbox")
    checkbox.click
    page.should have_text "#{@person.first_name[0..0]} #{@person.last_name}"
    
    checkbox = first(".shift-checkbox:checked")
    checkbox.click
    page.should_not have_text "#{@person.first_name[0..0]} #{@person.last_name}"
  end

  it "Looks at and filters county shifts by County and Category" do
    @person.positions = @positions
    @person.counties = @counties
    visit next_month_calendar
    click_on "County Shifts"

    # The county with shifts isn't the default, so no shifts should show up here
    page.should have_text("Categories")
    page.should have_text("Category 1")
    page.should_not have_text("OPEN")

    find("#choose-county").select("County 1")
    page.should have_text("Shift 1")
    page.should_not have_text("Shift 2")

    page.uncheck("Category 1")
    page.should have_text("Shift 1")
    page.should_not have_text("Shift 2")

    page.check("Category 2")
    page.uncheck("Category 1")
    page.should_not have_text("Shift 1")
    page.should_not have_text("Shift 2")

    find("#choose-county").select("County 2")
    page.should_not have_text("Shift 1")
    page.should have_text("Shift 2")
  end
end
