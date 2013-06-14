require 'spec_helper'

describe Scheduler::ShiftAssignmentsController do
  before(:each) do
    @person = FactoryGirl.create :person
    @chapter = @person.chapter
    @person2 = FactoryGirl.create :person, chapter: @chapter, counties: @person.counties, positions: @person.positions
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


  context "#index.ics" do
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

    pending "should include daily, weekly, monthly shifts"
    pending "daily shifts should have a date and time"
    pending "weekly/monthly shifts should have only a day"

    context "?show_shifts=all" do
      it "should access denied if a regular user" do
        3.times { FactoryGirl.create :shift_assignment }
        expect {
          get :index, format: :ics, api_token: @settings.calendar_api_token, show_shifts: 'all'
        }.to raise_error(CanCan::AccessDenied)
      end

      it 'should show all shifts I am a county admin for' do
        (0..2).map { |i| pers = FactoryGirl.create :person, chapter: @chapter, counties: @person.counties; FactoryGirl.create :shift_assignment, person: pers, date: (Date.today+6+i) }

        grant_role! 'county_dat_admin', @person.county_ids

        get :index, format: :ics, api_token: @settings.calendar_api_token, show_shifts: 'all'

        response.code.should eq "200"
        response.body.scan(/BEGIN:VEVENT/).count.should eq(8)
      end

      it "should merge other shifts into the same event" do
        (1..3).map { |i| pers = FactoryGirl.create :person, chapter: @chapter, counties: @person.counties; FactoryGirl.create :shift_assignment, person: pers, date: (Date.today+i) }

        grant_role! 'county_dat_admin', @person.county_ids

        get :index, format: :ics, api_token: @settings.calendar_api_token, show_shifts: 'all'

        response.code.should eq "200"
        response.body.scan(/BEGIN:VEVENT/).count.should eq(5)
      end
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
      @admin = FactoryGirl.create :person, chapter: @chapter,  counties: [@assignment.shift.county]
      @adminsettings = Scheduler::NotificationSetting.create id: @admin.id
      @adminsettings.update_attribute :email_all_swaps, true

      post :swap, id: @assignment.id, is_swap: true
      ActionMailer::Base.deliveries.should_not be_empty
      ActionMailer::Base.deliveries.first.body.should include("has made a shift available for swap")
    end

    it "should send user emails when marking a shift swappable" do
      @admin = FactoryGirl.create :person, chapter: @chapter,  counties: [@assignment.shift.county], positions: @person.positions
      @adminsettings = Scheduler::NotificationSetting.create id: @admin.id
      @adminsettings.update_attribute :email_swap_requested, true

      post :swap, id: @assignment.id, is_swap: true
      ActionMailer::Base.deliveries.should_not be_empty
      ActionMailer::Base.deliveries.first.body.should include("has made a shift available for swap")
    end

    it "should allow marking a shift as swappable with a recipient" do
      @admin = FactoryGirl.create :person, chapter: @chapter,  counties: [@assignment.shift.county], positions: @person.positions
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