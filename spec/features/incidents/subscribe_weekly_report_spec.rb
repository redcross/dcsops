require 'spec_helper'

describe "Weekly Report", :type => :feature do

  it "Should be subscribable" do
    grant_capability! :incidents_admin
    @scope = FactoryGirl.create :incidents_scope, region: @person.region, report_frequencies: 'weekly,daily'

    visit "/incidents/#{@scope.url_slug}"

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
    Incidents::ReportSubscription.where(person_id: @person).first!
  end
  
end