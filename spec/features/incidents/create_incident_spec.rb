require 'spec_helper'

describe "Manually create incident", :type => :feature do

	before do
		grant_role! :submit_incident_report
    grant_role! :incidents_admin
    FactoryGirl.create :incidents_scope, chapter: @person.chapter
    FactoryGirl.create :territory, chapter: @person.chapter, name: 'SF Territory', counties: ['San Francisco, CA']
  end

  it "Should be submittable to dat incident report" do
		visit "/incidents/#{@person.chapter.url_slug}"

		@incident_number = FactoryGirl.build(:incident).incident_number

		click_on "Submit Incident Report"
		click_on 'Create New Incident'

		fill_in 'Incident number*', with: @incident_number
		select '2013'
		select Date.today.strftime("%B")
		select Date.today.day.to_s

		select 'Fire', from: 'Incident type*'
		fill_in 'Search for address', with: '1663 market st sf'
		click_on 'Look Up Address'

		# Wait for AJAX to load the territory
		expect(page).to have_select('Territory*', selected: 'SF Territory')

		click_on 'Create Incident'

		expect(page).to have_text('New DAT Incident Report')
  end

  it "should be submittable with incident number sequence" do
  	seq = FactoryGirl.create :incident_number_sequence
  	@person.chapter.update incident_number_sequence: seq, incidents_report_editable: true

  	visit "/incidents/#{@person.chapter.url_slug}/incidents/new"

  	expect(page).to_not have_text('Incident number')

  	select '2013'
		select Date.today.strftime("%B")
		select Date.today.day.to_s
		select 'Fire', from: 'Incident type*'
		fill_in 'Search for address', with: '1663 market st sf'
		click_on 'Look Up Address'

		# Wait for AJAX to load the territory
		expect(page).to have_select('Territory*', selected: 'SF Territory')

		click_on 'Create Incident'

		expect(page).to have_text('Territory: SF Territory')

  end

end