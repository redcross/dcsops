require 'spec_helper'

describe "Incident Attachments", :type => :feature do

  it "Should be addable" do
    grant_role! 'submit_incident_report'

    incident = FactoryGirl.create :raw_incident, chapter: @person.chapter, area: @person.counties.first, date: Date.current
    FactoryGirl.create :incidents_scope, chapter: @person.chapter

    visit "/incidents/#{@person.chapter.url_slug}/incidents/#{incident.incident_number}"

    click_on "Attachments"
    click_on "Add Attachment"

    page.should have_text "Attachment type"

    attach_file("incidents_attachment[file]", "spec/files/attachments/test.txt")
    select "File", from: "Attachment type"
    fill_in "Name*", with: "Test Attachment"
    click_on "Create Attachment"

    page.should have_text "Test Attachment - File"
  end
end
