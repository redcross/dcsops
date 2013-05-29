require 'spec_helper'

describe Scheduler::CalendarController do
  include LoggedIn

  before(:each) do
    3.times {FactoryGirl.create :shift_assignment, date: Date.civil(2013, 8, 8)}
  end

  it "should render the whole calendar" do
    get :show, month: 'august', year: '2013'
    response.should be_success
  end

  it "should render a day" do
    get :day, date: '2013-08-08'
    response.should be_success
  end

  it "should render a month" do
    get :day, month: '2013-08'
    response.should be_success
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