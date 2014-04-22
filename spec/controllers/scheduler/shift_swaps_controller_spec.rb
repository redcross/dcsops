require 'spec_helper'

describe Scheduler::ShiftSwapsController do
  include LoggedIn

  before :each do
    @chapter = @person.chapter
    @person = FactoryGirl.create :person, chapter: @chapter
    @assignment = FactoryGirl.create :shift_assignment, person: @person
    @person2 = FactoryGirl.create :person, chapter: @chapter, counties: @person.counties, positions: @person.positions
    @settings = Scheduler::NotificationSetting.create id: @person.id
  end

  after :each do
    ActionMailer::Base.deliveries.clear
  end

  it "should show the assignment page" do
    get :show, shift_assignment_id: @assignment.id
  end

  it "should allow to mark a shift as swappable" do
    post :create, shift_assignment_id: @assignment.id
    @assignment.reload.available_for_swap.should be_true
    ActionMailer::Base.deliveries.should be_empty
  end

  it "should send admin emails when marking a shift swappable" do
    @admin = FactoryGirl.create :person, chapter: @chapter,  counties: [@assignment.shift.county]
    @adminsettings = Scheduler::NotificationSetting.create id: @admin.id
    @adminsettings.update_attribute :email_all_swaps, true

    post :create, shift_assignment_id: @assignment.id
    ActionMailer::Base.deliveries.should_not be_empty
    ActionMailer::Base.deliveries.first.body.should include("has made a shift available for swap")
  end

  it "should send user emails when marking a shift swappable" do
    @admin = FactoryGirl.create :person, chapter: @chapter,  counties: [@assignment.shift.county], positions: @person.positions
    @adminsettings = Scheduler::NotificationSetting.create id: @admin.id
    @adminsettings.update_attribute :email_swap_requested, true

    post :create, shift_assignment_id: @assignment.id
    ActionMailer::Base.deliveries.should_not be_empty
    ActionMailer::Base.deliveries.first.body.should include("has made a shift available for swap")
  end

  it "should allow marking a shift as swappable with a recipient" do
    @admin = FactoryGirl.create :person, chapter: @chapter,  counties: [@assignment.shift.county], positions: @person.positions
    @adminsettings = Scheduler::NotificationSetting.create id: @admin.id
    @adminsettings.update_attribute :email_all_swaps, true

    post :create, shift_assignment_id: @assignment.id, swap_to_id: @person2.id
    @assignment.reload.available_for_swap.should be_true

    ActionMailer::Base.deliveries.should have(2).items # Admin and recipient

    msg = ActionMailer::Base.deliveries.detect{|d| d.to.include? @person2.email}
    msg.should_not be_nil

    msg.body.should include("has asked you to take over their shift")

    msg = ActionMailer::Base.deliveries.detect{|d| d.to.include? @admin.email}
    msg.should_not be_nil

    msg.body.should include("has made a shift available for swap")
  end

  it "should allow accepting a swap" do
    Roster::Session.create @person2

    @assignment.update_attribute :available_for_swap, true

    post :confirm, shift_assignment_id: @assignment.id

    response.should be_redirect

    ActionMailer::Base.deliveries.should_not be_empty # 
    Scheduler::ShiftAssignment.last.person.should == @person2
  end

  it "should not allow accepting a swap to someone else" do
    @assignment.update_attribute :available_for_swap, true

    post :confirm, shift_assignment_id: @assignment.id, swap_to_id: @person2.id

    response.should redirect_to(scheduler_shift_assignment_shift_swap_path(@assignment))

    ActionMailer::Base.deliveries.should be_empty # 
  end

  it "should allow accepting a swap to someone else as admin" do
    grant_role! 'chapter_dat_admin'#, @person.county_ids
    @assignment.update_attribute :available_for_swap, true

    post :confirm, shift_assignment_id: @assignment.id, swap_to_id: @person2.id
    new_assignment = Scheduler::ShiftAssignment.last
    new_assignment.id.should_not == @assignment.id
    response.should redirect_to(new_scheduler_shift_assignment_shift_swap_path(new_assignment))
    expect{@assignment.reload}.to raise_error
    

    ActionMailer::Base.deliveries.should_not be_empty # 
    Scheduler::ShiftAssignment.last.person.should == @person2
  end

  it "should allow cancelling a swap" do
    @assignment.available_for_swap = true
    @assignment.save

    delete :destroy, shift_assignment_id: @assignment.id

    @assignment.reload.available_for_swap.should be_false
    ActionMailer::Base.deliveries.should be_empty
  end
end
