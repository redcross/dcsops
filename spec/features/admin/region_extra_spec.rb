require 'spec_helper'

# These pages aren't actually accessible from the app without
# knowing the URL.  However, after going over them with product,
# we decided to keep them live.  Which means they need tests!
describe "Region Extra Configuration Pages", :type => :feature do
  before(:each) do
    grant_role! :region_config
  end

  it "Update the region counties" do
    visit "/admin/regions/#{@person.region.url_slug}/counties"

    click_on "Add Row"

    county_id = @person.region.counties.first.id

    within("#resource-#{county_id}") do
      fill_in "roster_county[abbrev]", with: "County"
      fill_in "roster_county[vc_regex_raw]", with: "count.*"
      click_on "Save"
    end

    within("#resource-") do
      fill_in "roster_county[name]", with: "Test County"
      fill_in "roster_county[abbrev]", with: "TC"
      fill_in "roster_county[vc_regex_raw]", with: "test.*"
      click_on "Save"
    end
    page.should have_text "2"
  end

  it "Update the region positions" do
    visit "/admin/regions/#{@person.region.url_slug}/positions"

    click_on "Add Row"

    position_id = @person.region.positions.first.id
    within("#resource-#{position_id}") do
      fill_in "roster_position[abbrev]", with: "Position"
      fill_in "roster_position[vc_regex_raw]", with: "count.*"
      click_on "Save"
    end

    within("#resource-") do
      fill_in "roster_position[name]", with: "Test Position"
      fill_in "roster_position[abbrev]", with: "TP"
      fill_in "roster_position[vc_regex_raw]", with: "test.*"
      click_on "Save"
    end
    page.should have_text "3"
  end

  it "Update the region shifts" do
    #FactoryGirl.create :shift_category, region: @person.region
    group = FactoryGirl.create :shift_time, region: @person.region, start_offset: 10.hours, end_offset: 22.hours
    categories = (1..2).map{|i| FactoryGirl.create :shift_category, name: "Category #{i}", region: @person.region}

    visit "/admin/regions/#{@person.region.url_slug}/shifts"

    click_on "Add Row"

    within("#resource-") do
      fill_in "scheduler_shift[name]", with: "Test Shift"
      fill_in "scheduler_shift[abbrev]", with: "Abbrev"
      fill_in "scheduler_shift[ordinal]", with: "1"
      all("#scheduler_shift_county_input select option")[1].select_option
      fill_in "scheduler_shift[max_signups]", with: "2"
      fill_in "scheduler_shift[min_desired_signups]", with: "1"
      all("#scheduler_shift_shift_category_input select option")[1].select_option
      click_on "Save"
    end

    page.should have_text "1"
  end

  it "Update the vc positions" do
    # This test is a bit awkward, because we're testing a json api
    # and capybara isn't really the best way to test that.  However,
    # as a base case, it's good enough before we build out a better
    # api testing solution that uses the login mechanics correctly.
    visit "/admin/regions/#{@person.region.url_slug}/vc_positions"
    page.should have_text "No filter regex specified"

    position_data = {"Position 1" => 4, "Position 2" => 10}
    @person.region.vc_import_data = FactoryGirl.create :vc_import_data, position_data: position_data

    visit "/admin/regions/#{@person.region.url_slug}/vc_positions?regex=Position"

    page.should have_text("Position 1")

    visit "/"
  end
end
