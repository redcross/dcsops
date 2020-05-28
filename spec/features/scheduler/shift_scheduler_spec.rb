require 'spec_helper'

describe "Shift Scheduler Spec", :type => :feature do

  def next_month_calendar
    next_month = Date.current.next_month.strftime("%B").downcase
    next_month_year = Date.current.next_month.strftime("%Y")
    "/scheduler/calendar/#{next_month_year}/#{next_month}"
  end

  before :each do
    # This has to happen up here, so that the county/position/category create
    # includes this person, because the chapters have to match before FactoryGirl
    # creates these.
    @other_person = FactoryGirl.create(:person, rco_id: rand(100000), chapter: @person.chapter)

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
    
    first(".shift-checkbox").click
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

  it "Allows a swap between two users" do
    @person.positions = @positions
    @person.counties = @counties

    @other_person = FactoryGirl.create(:person, rco_id: rand(100000))
    @other_person.counties = @counties
    @other_person.positions = @positions

    visit next_month_calendar
    all(".shift-checkbox")[5].click
    page.should have_text "#{@person.first_name[0..0]} #{@person.last_name}"
    visit "/scheduler/"

    click_on "All Upcoming Shifts"
    click_on "Swap"
    click_on "Start Swap"

    logout
    login_person @other_person
    visit "/scheduler/"
    click_on "Claim"
    click_on "Confirm Swap"
    visit "/scheduler/"
    page.should_not have_text "You have no upcoming shifts scheduled."

    logout
    login_person @person
    visit "/scheduler/"
    page.should have_text "You have no upcoming shifts scheduled."
  end

  it "Can view another person's shifts" do
    @person.positions = @positions
    @person.counties = @counties

    @other_person.positions = @positions
    @other_person.counties = @counties

    visit next_month_calendar
    all(".shift-checkbox")[5].click
    page.should have_text "#{@person.first_name[0..0]} #{@person.last_name}"
    logout

    login_person @other_person
    visit next_month_calendar
    page.should have_text "Shift 1"
    page.should have_text "#{@person.first_name[0..0]} #{@person.last_name}"
    page.should_not have_css ".my-shift"
    fill_in "select-person", with: @person.first_name[0..2]
    page.should have_text @person.full_name
    find('.tt-suggestion', text: @person.full_name).click
    page.should have_css ".my-shift"
  end

  it "Can assign another person a shift as admin" do
    @person.positions = @positions
    @person.counties = @counties

    @other_person.positions = @positions
    @other_person.counties = @counties

    grant_role! 'county_dat_admin', @other_person.county_ids, @other_person

    visit next_month_calendar
    all(".shift-checkbox")[5].click
    page.should have_text "#{@person.first_name[0..0]} #{@person.last_name}"
    logout

    login_person @other_person
    visit next_month_calendar
    page.should have_text "Shift 1"
    page.should have_text "#{@person.first_name[0..0]} #{@person.last_name}"
    page.should_not have_css ".my-shift"
    fill_in "select-person", with: @person.first_name[0..2]
    page.should have_text @person.full_name
    find('.tt-suggestion', text: @person.full_name).click

    all(".shift-checkbox")[5].click
    page.should have_text "#{@person.first_name[0..0]} #{@person.last_name}", count: 2
  end
end
