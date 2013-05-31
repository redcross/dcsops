require 'spec_helper'

describe Scheduler::ShiftAssignmentsController do
  before(:each) do
    @person = FactoryGirl.create :person
    @person2 = FactoryGirl.create :person, counties: @person.counties, positions: @person.positions
    @shift = FactoryGirl.create :shift, county: @person.counties.first, positions: @person.positions

    @assignments = (1..5).map{|i| Scheduler::ShiftAssignment.create! person:@person, date:Date.today+i, shift:@shift}

    @settings = Scheduler::NotificationSetting.create id: @person.id
  end

  it "when not logged in, should be unauthorized" do
    get :index, format: :ics

    response.code.should eq "401"
  end

  it "with invalid api token, should be unauthorized" do
    get :index, format: :ics, api_token: "test123"

    response.code.should eq "401"
  end


  context do
    render_views

    it "should allow exporting my shifts to calendar" do
      get :index, format: :ics, api_token: @settings.calendar_api_token

      response.code.should eq "200"
      response.body.scan(/BEGIN:VEVENT/).count.should eq(5)
    end

    it "should only include my shifts on the calendar" do
      3.times { FactoryGirl.create :shift_assignment }

      get :index, format: :ics, api_token: @settings.calendar_api_token

      response.code.should eq "200"
      response.body.scan(/BEGIN:VEVENT/).count.should eq(5)
    end
  end

  context "swaps" do
    include LoggedIn

    before :each do
      @assignment = @assignments.first
    end

    after :each do
      ActionMailer::Base.deliveries.clear
    end

    it "should show the assignment page" do
      get :show, id: @assignment.id
    end

    it "should show the swap page" do
      get :swap, id: @assignment.id
    end

    it "should allow to mark a shift as swappable" do
      post :swap, id: @assignment.id, is_swap: true
      @assignment.reload.available_for_swap.should be_true
      ActionMailer::Base.deliveries.should be_empty
    end

    it "should send admin emails when marking a shift swappable" do
      @admin = FactoryGirl.create :person, counties: [@assignment.shift.county]
      @adminsettings = Scheduler::NotificationSetting.create id: @admin.id
      @adminsettings.update_attribute :email_all_swaps, true

      post :swap, id: @assignment.id, is_swap: true
      ActionMailer::Base.deliveries.should_not be_empty
      ActionMailer::Base.deliveries.first.body.should include("has made a shift available for swap")
    end

    it "should send user emails when marking a shift swappable" do
      @admin = FactoryGirl.create :person, counties: [@assignment.shift.county], positions: @person.positions
      @adminsettings = Scheduler::NotificationSetting.create id: @admin.id
      @adminsettings.update_attribute :email_swap_requested, true

      post :swap, id: @assignment.id, is_swap: true
      ActionMailer::Base.deliveries.should_not be_empty
      ActionMailer::Base.deliveries.first.body.should include("has made a shift available for swap")
    end

    it "should allow marking a shift as swappable with a recipient" do
      @admin = FactoryGirl.create :person, counties: [@assignment.shift.county], positions: @person.positions
      @adminsettings = Scheduler::NotificationSetting.create id: @admin.id
      @adminsettings.update_attribute :email_all_swaps, true

      post :swap, id: @assignment.id, is_swap: true, swap_to_id: @person2.id
      @assignment.reload.available_for_swap.should be_true
      ActionMailer::Base.deliveries.should_not be_empty # 

      msg = ActionMailer::Base.deliveries.detect{|d| d.to.include? @person2.email}
      msg.should_not be_nil

      msg.body.should include("has asked you to take over their shift")

      msg = ActionMailer::Base.deliveries.detect{|d| d.to.include? @admin.email}
      msg.should_not be_nil

      msg.body.should include("has made a shift available for swap")
    end

    it "should allow accepting a swap" do
      Roster::Session.create @person2

      @assignment.available_for_swap = true
      @assignment.save

      post :swap, id: @assignment.id, accept_swap: true

      response.should be_redirect

      ActionMailer::Base.deliveries.should_not be_empty # 
      Scheduler::ShiftAssignment.last.person.should == @person2
    end

    it "should allow accepting a swap as admin" do
      @assignment.available_for_swap = true
      @assignment.save

      post :swap, id: @assignment.id, accept_swap: true, swap_to_id: @person2.id

      response.should be_redirect

      ActionMailer::Base.deliveries.should_not be_empty # 
      Scheduler::ShiftAssignment.last.person.should == @person2
    end

    it "should allow cancelling a swap" do
      @assignment.available_for_swap = true
      @assignment.save

      post :swap, id: @assignment.id, cancel_swap: true

      @assignment.reload.available_for_swap.should be_false
      ActionMailer::Base.deliveries.should be_empty
    end
  end
end