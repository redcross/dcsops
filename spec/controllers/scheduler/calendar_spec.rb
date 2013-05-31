require 'spec_helper'

describe Scheduler::CalendarController do
  include LoggedIn
  render_views

  let( :date) { Date.civil(2013,8,8) }
  let( :weekly_date) { date.at_beginning_of_week }
  let( :monthly_date) { date.at_beginning_of_month }

  before(:each) do
    @ch = FactoryGirl.create :chapter
    @person.chapter = @ch; @person.save

    @dg = FactoryGirl.create :shift_group, chapter: @ch, period: 'daily'
    @wg = FactoryGirl.create :shift_group, chapter: @ch, period: 'weekly', start_offset: 0, end_offset: 7.days
    @mg = FactoryGirl.create :shift_group, chapter: @ch, period: 'monthly', start_offset: 0, end_offset: 31

    @ds = FactoryGirl.create :shift, shift_group: @dg, county: @person.counties.first, positions: @person.positions
    @ws = FactoryGirl.create :shift, shift_group: @wg, county: @person.counties.first, positions: @person.positions
    @ms = FactoryGirl.create :shift, shift_group: @mg, county: @person.counties.first, positions: @person.positions

    FactoryGirl.create :shift_assignment, shift: @ds, person: @person, date: date
    FactoryGirl.create :shift_assignment, shift: @ws, person: @person, date: weekly_date
    FactoryGirl.create :shift_assignment, shift: @ms, person: @person, date: monthly_date
  end

  it "should render the whole calendar" do
    get :show, month: 'august', year: '2013'
    response.should be_success
  end

  describe "day" do

    let(:shift) {@ds}

    it "should render" do
      get :day, date: date.to_s
      response.should be_success
      response.body.should match(@ds.name)
    end

    it "should be possible to sign up" do
      get :day, date: date.tomorrow.to_s
      response.should be_success
      response.body.should match("checkbox")
    end

    it "should be possible to un-sign up" do
      get :day, date: date.to_s
      response.should be_success
      response.body.should match("checkbox")
    end

    it "should not show shift if the shift has ended" do
      shift.update_attribute(:shift_ends, date.yesterday)
      get :day, date: date.to_s
      response.should be_success
      response.body.should_not match(shift.name)
    end

    it "should not show shift if the shift hasn't started" do
      shift.update_attribute(:shift_begins, date.tomorrow)
      get :day, date: date.yesterday.to_s
      response.should be_success
      response.body.should_not match(shift.name)
    end

    it "should not be possible to un-sign up if the shift is frozen" do
      shift.update_attribute(:signups_frozen_before, date.tomorrow.tomorrow)
      get :day, date: date.to_s
      response.should be_success
      response.body.should_not match("checkbox")
    end

  end

  describe "week" do

    let(:shift) {@ws}

    it "should render" do
      get :day, date: weekly_date.to_s, period: 'week'
      response.should be_success
      response.body.should match(shift.name)
    end

    it "should be possible to sign up" do
      get :day, date: weekly_date.next_week.to_s, period: 'week'
      response.should be_success
      response.body.should match("checkbox")
    end

    it "should be possible to un-sign up" do
      get :day, date: weekly_date.to_s, period: 'week'
      response.should be_success
      response.body.should match("checkbox")
    end

    it "should not show shift if the shift has ended" do
      shift.update_attribute(:shift_ends, weekly_date.last_week)
      get :day, date: weekly_date.to_s, period: 'week'
      response.should be_success
      response.body.should_not match(shift.name)
    end

    it "should not show shift if the shift hasn't started" do
      shift.update_attribute(:shift_begins, weekly_date.next_week)
      get :day, date: weekly_date.to_s, period: 'week'
      response.should be_success
      response.body.should_not match(shift.name)
    end

    it "should not be possible to un-sign up if the shift is frozen" do
      shift.update_attribute(:signups_frozen_before, weekly_date.next_week)
      get :day, date: weekly_date.to_s, period: 'week'
      response.should be_success
      response.body.should_not match("checkbox")
    end

  end

  describe "month" do

    let(:shift) {@ms}

    it "should render" do
      get :day, date: monthly_date.to_s, period: 'monthly'
      response.should be_success
      response.body.should match(shift.name)
    end

    it "should be possible to sign up" do
      get :day, date: monthly_date.next_month.to_s, period: 'monthly'
      response.should be_success
      response.body.should match("checkbox")
    end

    it "should be possible to un-sign up" do
      get :day, date: monthly_date.to_s, period: 'monthly'
      response.should be_success
      response.body.should match("checkbox")
    end

    it "should not show shift if the shift has ended" do
      shift.update_attribute(:shift_ends, monthly_date.last_month)
      get :day, date: monthly_date.to_s, period: 'monthly'
      response.should be_success
      response.body.should_not match(shift.name)
    end

    it "should not show shift if the shift hasn't started" do
      shift.update_attribute(:shift_begins, monthly_date.next_month)
      get :day, date: monthly_date.to_s, period: 'monthly'
      response.should be_success
      response.body.should_not match(shift.name)
    end

    it "should not be possible to un-sign up if the shift is frozen" do
      shift.update_attribute(:signups_frozen_before, monthly_date.next_month)
      get :day, date: monthly_date.to_s, period: 'monthly'
      response.should be_success
      response.body.should_not match("checkbox")
    end

  end

  it "should render the month" do
    get :day, month: "2013-08"
    response.should be_success
    response.body.should match(@ds.name)
    response.body.should match(@ws.name)
    response.body.should match(@ms.name)
  end

  it "should render open shifts" do
    get :show, month: 'august', year: '2013', display: 'open_shifts'
    response.should be_success
  end

  it "should render the spreadsheet" do
    get :show, month: 'august', year: '2013', display: 'spreadsheet'
    response.should be_success
  end

end