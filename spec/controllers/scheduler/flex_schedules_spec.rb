require 'spec_helper'

describe Scheduler::FlexSchedulesController do
  include LoggedIn
  before(:each) do
    @sched = Scheduler::FlexSchedule.create id: @person.id
  end

  describe "#index" do

    it "should render" do
      get :index
      response.should be_success
    end

    it "should filter by county" do
      get :index, county: @person.county_ids.first
      response.should be_success
    end
  end

  describe "#show" do
    it "should render" do
      get :show, id: @person.id
      response.should be_success
    end

    it "should allow updating" do
      put :update, id: @person.id, scheduler_flex_schedule: {available_monday_day: true}, format: 'json'
      response.should be_success
      @sched.reload.available_monday_day.should eq true
    end
  end
end