require 'spec_helper'

describe Scheduler::FlexSchedulesController, :type => :controller do
  include LoggedIn
  render_views

  before(:each) do
    @sched = Scheduler::FlexSchedule.create id: @person.id
  end

  describe "#index" do

    it "should render" do
      get :index
      expect(response).to be_success
    end

    it "should filter by county" do
      get :index, county: @person.county_ids.first
      expect(response).to be_success
    end

    it "should render when the person has no county" do
      @person.counties = []; @person.save
      get :index
      expect(response).to be_success
    end
  end

  describe "#show" do
    it "should render" do
      get :show, id: @person.id
      expect(response).to be_success
    end

    it "should allow updating" do
      put :update, id: @person.id, scheduler_flex_schedule: {available_monday_day: true}, format: 'json'
      expect(response).to be_success
      expect(@sched.reload.available_monday_day).to eq true
    end
  end
end