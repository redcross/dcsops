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

    it "should filter by shift territory" do
      get :index, params: { shift_territory: @person.shift_territory_ids.first }
      expect(response).to be_success
    end

    it "should render when the person has no shift territory" do
      @person.shift_territories = []; @person.save
      get :index
      expect(response).to be_success
    end
  end

  describe "#show" do
    it "should render" do
      get :show, params: { id: @person.id }
      expect(response).to be_success
    end

    it "should allow updating" do
      put :update, params: { id: @person.id, scheduler_flex_schedule: {available_monday_day: true}, format: 'json' }
      expect(response).to be_success
      expect(@sched.reload.available_monday_day).to eq true
    end
  end
end