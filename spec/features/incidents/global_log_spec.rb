require 'spec_helper'

describe "View Global Log" do

  it "Should be submittable" do
    grant_role! :incidents_admin
    @chapter = @person.chapter
    @chapter.incidents_use_global_log = true
    @chapter.save!
    FactoryGirl.create :incidents_scope, chapter: @person.chapter

    @log = FactoryGirl.create :event_log, chapter: @chapter, person: @person

    visit "/incidents/#{@chapter.url_slug}"

    click_link "ECC Log"
    
    page.should have_text(@log.message)

    @new_log = FactoryGirl.attributes_for :event_log
    click_button "Add Log"
    select 'Note', from: 'Event*'
    fill_in 'Message*', with: @new_log[:message]

    click_button "Create Event log"

    page.should_not have_text("Add Event")
    page.should have_text(@new_log[:message])

    latest_log = Incidents::EventLog.last
    latest_log.message.should == @new_log[:message]
  end
  
end