require 'spec_helper'

describe "Shift Scheduler Spec", :type => :feature do

  def month_of_interest_link
    # If we're in the first half of the month, use the current month,
    # otherwise next month.  We need to ensure that the shifts we're
    # signing up for aren't too far out so they don't show up for stuff
    # like swaps.
    if Date.current.day < 15
      d = Date.current
    else
      d = Date.current.next_month
    end
    month_str = d.strftime("%B").downcase
    year_str = d.strftime("%Y")
    "/scheduler/calendar/#{year_str}/#{month_str}"
  end

  before :each do
    # This has to happen up here, so that the shift_territory/position/category create
    # includes this person, because the regions have to match before FactoryGirl
    # creates these.
    @other_person = FactoryGirl.create(:person, rco_id: rand(100000), region: @person.region)

    group = FactoryGirl.create :shift_time, region: @person.region, start_offset: 10.hours, end_offset: 22.hours
    @shift_territories = (1..2).map{|i| FactoryGirl.create :shift_territory, name: "Shift Territory #{i}", region: @person.region}
    @positions = (1..2).map{|i| FactoryGirl.create :position, name: "Position #{i}", region: @person.region}
    @categories = (1..2).map{|i| FactoryGirl.create :shift_category, name: "Category #{i}", region: @person.region}

    FactoryGirl.create :shift,
      shift_times: [group],
      name: "Shift 1",
      positions: [@positions.find{|p| p.name == "Position 1"}],
      shift_category: @categories.find{|c| c.name == "Category 1"},
      shift_territory: @shift_territories.find{|c| c.name == "Shift Territory 1"}

    FactoryGirl.create :shift,
      shift_times: [group],
      name: "Shift 2",
      positions: [@positions.find{|p| p.name == "Position 2"}],
      shift_category: @categories.find{|c| c.name == "Category 2"},
      shift_territory: @shift_territories.find{|c| c.name == "Shift Territory 2"}
  end

  it "Visits this months schedule" do
    visit "/scheduler/"

    next_month = Date.current.next_month.strftime("%B")

    within find("strong", text: next_month).find(:xpath, "./following-sibling::div") do
      click_on "Sign Up"
    end

    page.should have_text("My Positions")
    page.should have_text("Shifts by Territory")
    page.should have_text("Available Shifts")
    page.should have_text(next_month)
  end

  it "Looks at all shifts" do
    visit month_of_interest_link
    click_on "All Shifts"

    page.should have_text("OPEN")
    page.should have_text("Shift 1")
  end

  it "Signs up for a shift" do
    @person.positions = @positions[0..0]
    @person.shift_territories = @shift_territories

    visit "/scheduler/"
    page.should have_text "You have no upcoming shifts scheduled."
    page.should have_text "#{Date.current.next_month.end_of_month.day * @person.positions.length} Shifts Available"

    visit month_of_interest_link
    page.should have_text "OPEN"
    
    checkbox = first(".shift-checkbox")
    checkbox.click
    page.should have_text "#{@person.first_name[0..0]} #{@person.last_name}"

    visit "/scheduler/"
    page.should_not have_text "You have no upcoming shifts scheduled."
  end

  it "Signs up and removes sign up for a shift" do
    @person.positions = @positions[0..0]
    @person.shift_territories = @shift_territories

    visit month_of_interest_link
    
    first(".shift-checkbox").click
    page.should have_text "#{@person.first_name[0..0]} #{@person.last_name}"
    
    checkbox = first(".shift-checkbox:checked")
    checkbox.click
    page.should_not have_text "#{@person.first_name[0..0]} #{@person.last_name}"
  end

  it "Looks at and filters shift territory shifts by Shift Territory and Category" do
    @person.positions = @positions
    @person.shift_territories = @shift_territories
    visit month_of_interest_link
    click_on "Shifts by Territory"

    # The shift territory with shifts isn't the default, so no shifts should show up here
    page.should have_text("Categories")
    page.should have_text("Category 1")
    page.should_not have_text("OPEN")

    find("#choose-shift_territory").select("Shift Territory 1")
    page.should have_text("Shift 1")
    page.should_not have_text("Shift 2")

    page.uncheck("Category 1")
    page.should have_text("Shift 1")
    page.should_not have_text("Shift 2")

    page.check("Category 2")
    page.uncheck("Category 1")
    page.should_not have_text("Shift 1")
    page.should_not have_text("Shift 2")

    find("#choose-shift_territory").select("Shift Territory 2")
    page.should_not have_text("Shift 1")
    page.should have_text("Shift 2")
  end

  it "Allows a swap between two users" do
    @person.positions = @positions
    @person.shift_territories = @shift_territories

    @other_person = FactoryGirl.create(:person, rco_id: rand(100000))
    @other_person.shift_territories = @shift_territories
    @other_person.positions = @positions

    visit month_of_interest_link
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
    @person.shift_territories = @shift_territories

    @other_person.positions = @positions
    @other_person.shift_territories = @shift_territories

    visit month_of_interest_link
    all(".shift-checkbox")[5].click
    page.should have_text "#{@person.first_name[0..0]} #{@person.last_name}"
    logout

    login_person @other_person
    visit month_of_interest_link
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
    @person.shift_territories = @shift_territories

    @other_person.positions = @positions
    @other_person.shift_territories = @shift_territories

    grant_capability! 'shift_territory_dat_admin', @other_person.shift_territory_ids, @other_person

    visit month_of_interest_link
    all(".shift-checkbox")[5].click
    page.should have_text "#{@person.first_name[0..0]} #{@person.last_name}"
    logout

    login_person @other_person
    visit month_of_interest_link
    page.should have_text "Shift 1"
    page.should have_text "#{@person.first_name[0..0]} #{@person.last_name}"
    page.should_not have_css ".my-shift"
    fill_in "select-person", with: @person.first_name[0..2]
    page.should have_text @person.full_name
    find('.tt-suggestion', text: @person.full_name).click

    page.should have_css(".shift-checkbox:enabled")
    all(".shift-checkbox")[5].click
    page.should have_text "#{@person.first_name[0..0]} #{@person.last_name}", count: 2
  end
end
