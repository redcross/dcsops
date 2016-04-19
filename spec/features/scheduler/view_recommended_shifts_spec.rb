require 'spec_helper'

describe "View Recommended Shifts", type: :feature do

	it "should show a Recommended Shifts button" do
		visit "/scheduler/calendar/2016/april"
		expect(page).to have_selector(:link_or_button, 'Recommended Shifts')
	end
end