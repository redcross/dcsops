require 'spec_helper'

describe Scheduler::Ability do
  before(:each) do
    @person = FactoryGirl.create :person
    @position = @person.positions.first

    @other_person = FactoryGirl.create :person, chapter: @person.chapter, counties: @person.counties
  end

  let(:ability) { Scheduler::Ability.new(@person) }

  delegate :can?, :cannot?, to: :ability

  it "should be createable" do
    ability.should_not be_nil
  end

  context "As user" do
    it "can read and update own notification setting" do
      can?(:read, Scheduler::NotificationSetting.new( id: @person.id)).should be_true
      can?(:update, Scheduler::NotificationSetting.new( id: @person.id)).should be_true
    end

    it "can't read and update other notification setting" do
      cannot?(:read, Scheduler::NotificationSetting.new( id: @other_person.id)).should be_true
      cannot?(:update, Scheduler::NotificationSetting.new( id: @other_person.id)).should be_true
    end

    it "can read and update own flex schedule" do
      can?(:read, Scheduler::FlexSchedule.new( id: @person.id)).should be_true
      can?(:update, Scheduler::FlexSchedule.new( id: @person.id)).should be_true
    end

    it "can't read and update own flex schedule" do
      cannot?(:read, Scheduler::FlexSchedule.new( id: @other_person.id)).should be_true
      cannot?(:update, Scheduler::FlexSchedule.new( id: @other_person.id)).should be_true
    end

    it "can manage own shifts" do
      ass = Scheduler::ShiftAssignment.new person: @person

      can?(:create, ass).should be_true
      can?(:read, ass).should be_true
      can?(:destroy, ass).should be_true
      can?(:swap, ass).should be_true
    end

    it "can't manage other's shifts" do
      ass = Scheduler::ShiftAssignment.new person: @other_person

      cannot?(:create, ass).should be_true
      cannot?(:read, ass).should be_true
      cannot?(:destroy, ass).should be_true
      cannot?(:swap, ass).should be_true
    end

    it "can swap other shifts when available" do
      ass = Scheduler::ShiftAssignment.new person: @other_person, available_for_swap: true

      can?(:swap, ass).should be_true
    end
  end

  context "as county dat admin" do
    before(:each) do
      @position.grants_role = 'county_dat_admin'
      @position.role_scope = @person.county_ids
      @position.save

      @non_county_person = FactoryGirl.create :person, chapter: @person.chapter
    end

    it "can read people in county" do
      can?(:read, @other_person).should be_true
      cannot?(:read, @non_county_person).should be_true
    end

    it "can manage county's shifts" do
      ass = Scheduler::ShiftAssignment.new person: @other_person

      can?(:create, ass).should be_true
      can?(:read, ass).should be_true
      can?(:destroy, ass).should be_true
      can?(:swap, ass).should be_true
    end

    it "can't manage other county's shifts" do
      ass = Scheduler::ShiftAssignment.new person: @non_county_person

      cannot?(:create, ass).should be_true
      cannot?(:read, ass).should be_true
      cannot?(:destroy, ass).should be_true
      cannot?(:swap, ass).should be_true
    end

    it "can manage only own county's dispatch config" do
      config = Scheduler::DispatchConfig.new id: @person.county_ids.first

      can?(:read, config).should be_true
      can?(:update, config).should be_true
    end

    it "can't manage other county's dispatch config" do
      config = Scheduler::DispatchConfig.new id: @non_county_person.county_ids.first

      cannot?(:read, config).should be_true
      cannot?(:update, config).should be_true
    end

    it "can read and update county person's notification setting" do
      can?(:read, Scheduler::NotificationSetting.new( id: @other_person.id)).should be_true
      can?(:update, Scheduler::NotificationSetting.new( id: @other_person.id)).should be_true
    end

    it "can't read and update other county person's notification setting" do
      cannot?(:read, Scheduler::NotificationSetting.new( id: @non_county_person.id)).should be_true
      cannot?(:update, Scheduler::NotificationSetting.new( id: @non_county_person.id)).should be_true
    end

    it "can read and update county person's flex schedule" do
      can?(:read, Scheduler::FlexSchedule.new( id: @other_person.id)).should be_true
      can?(:update, Scheduler::FlexSchedule.new( id: @other_person.id)).should be_true
    end

    it "can't read and update other county person's flex schedule" do
      cannot?(:read, Scheduler::FlexSchedule.new( id: @non_county_person.id)).should be_true
      cannot?(:update, Scheduler::FlexSchedule.new( id: @non_county_person.id)).should be_true
    end

    it "can manage own county's shifts" do
      shift = Scheduler::Shift.new county_id: @person.county_ids.first

      can?(:read, shift).should be_true
      can?(:update, shift).should be_true
      can?(:update_shifts, shift).should be_true
    end

    it "can't manage other county's shifts" do
      shift = Scheduler::Shift.new county_id: @non_county_person.county_ids.first

      cannot?(:read, shift).should be_true
      cannot?(:update, shift).should be_true
      cannot?(:update_shifts, shift).should be_true
    end

    it "can get admin notifications only on own setting" do
      can?(:receive_admin_notifications, Scheduler::NotificationSetting.new( id: @person.id)).should be_true
      cannot?(:receive_admin_notifications, Scheduler::NotificationSetting.new( id: @other_person.id)).should be_true
    end
  end
end


