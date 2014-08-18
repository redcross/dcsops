require 'spec_helper'

describe "Weekly Report", :type => :feature do

  it "Should be subscribable" do
    grant_role! :incidents_admin
    @chapter = @person.chapter
    @chapter.incidents_enabled_report_frequencies = 'weekly,daily'
    @chapter.save!
    FactoryGirl.create :incidents_scope, chapter: @person.chapter

    visit "/incidents/#{@chapter.url_slug}"

    click_link "Daily/Weekly Report"

    click_on 'Subscribe'
    expect(page).to have_css('a.editable', text: 'Weekly')

    sub = get_sub
    expect(sub).to_not be_nil
    expect(sub.frequency).to eq('weekly')

    click_on 'Weekly'
    select 'Daily'

    find('.editable-submit').click
    expect(page).to have_css('a.editable', text: 'Daily')

    expect(get_sub.frequency).to eq('daily')

    click_on 'Unsubscribe'
    find('input[value=Subscribe]')

    expect{
      get_sub
    }.to raise_error(ActiveRecord::RecordNotFound)

  end

  def get_sub
    Incidents::ReportSubscription.where{person_id == my{@person}}.first!
  end
  
end