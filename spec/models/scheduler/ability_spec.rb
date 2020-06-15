require 'spec_helper'

describe Scheduler::Ability, :type => :model do
  before(:each) do
    @person = FactoryGirl.create :person
    @position = @person.positions.first

    @other_person = FactoryGirl.create :person, region: @person.region, shift_territories: @person.shift_territories
  end

  let(:ability) { Scheduler::Ability.new(@person) }

  delegate :can?, :cannot?, to: :ability

  it "should be createable" do
    expect(ability).not_to be_nil
  end

  context "As user" do
    it "can read and update own notification setting" do
      expect(can?(:read, Scheduler::NotificationSetting.new( id: @person.id))).to be_truthy
      expect(can?(:update, Scheduler::NotificationSetting.new( id: @person.id))).to be_truthy
    end

    it "can't read and update other notification setting" do
      expect(cannot?(:read, Scheduler::NotificationSetting.new( id: @other_person.id))).to be_truthy
      expect(cannot?(:update, Scheduler::NotificationSetting.new( id: @other_person.id))).to be_truthy
    end

    it "can read and update own flex schedule" do
      expect(can?(:read, Scheduler::FlexSchedule.new( id: @person.id))).to be_truthy
      expect(can?(:update, Scheduler::FlexSchedule.new( id: @person.id))).to be_truthy
    end

    it "can't read and update own flex schedule" do
      expect(cannot?(:read, Scheduler::FlexSchedule.new( id: @other_person.id))).to be_truthy
      expect(cannot?(:update, Scheduler::FlexSchedule.new( id: @other_person.id))).to be_truthy
    end

    it "can manage own shifts" do
      ass = Scheduler::ShiftAssignment.new person: @person

      expect(can?(:create, ass)).to be_truthy
      expect(can?(:read, ass)).to be_truthy
      expect(can?(:destroy, ass)).to be_truthy
      expect(can?(:swap, ass)).to be_truthy
    end

    it "can't manage other's shifts" do
      ass = Scheduler::ShiftAssignment.new person: @other_person

      expect(cannot?(:create, ass)).to be_truthy
      expect(cannot?(:read, ass)).to be_truthy
      expect(cannot?(:destroy, ass)).to be_truthy
      expect(cannot?(:swap, ass)).to be_truthy
    end

    it "can swap other shifts when available" do
      ass = Scheduler::ShiftAssignment.new person: @other_person, available_for_swap: true

      expect(can?(:confirm, Scheduler::ShiftSwap.new(ass, nil))).to be_truthy
    end
  end

  context "as shift_territory dat admin" do
    before(:each) do
      grant_role! 'shift_territory_dat_admin', @person.shift_territory_ids

      @non_shift_territory_person = FactoryGirl.create :person, region: @person.region
    end

    it "can read people in shift_territory" do
      expect(can?(:read, @other_person)).to be_truthy
      expect(cannot?(:read, @non_shift_territory_person)).to be_truthy
    end

    it "can manage shift territory's shifts" do
      ass = Scheduler::ShiftAssignment.new person: @other_person

      expect(can?(:create, ass)).to be_truthy
      expect(can?(:read, ass)).to be_truthy
      expect(can?(:destroy, ass)).to be_truthy
      expect(can?(:swap, ass)).to be_truthy
    end

    it "can't manage other shift territory's shifts" do
      ass = Scheduler::ShiftAssignment.new person: @non_shift_territory_person

      expect(cannot?(:create, ass)).to be_truthy
      expect(cannot?(:read, ass)).to be_truthy
      expect(cannot?(:destroy, ass)).to be_truthy
      expect(cannot?(:swap, ass)).to be_truthy
    end

    it "can manage only own shift territory's dispatch config" do
      config = Scheduler::DispatchConfig.new id: @person.shift_territory_ids.first

      expect(can?(:read, config)).to be_truthy
      expect(can?(:update, config)).to be_truthy
    end

    it "can't manage other shift territory's dispatch config" do
      config = Scheduler::DispatchConfig.new id: @non_shift_territory_person.shift_territory_ids.first

      expect(cannot?(:read, config)).to be_truthy
      expect(cannot?(:update, config)).to be_truthy
    end

    it "can read and update shift territory person's notification setting" do
      expect(can?(:read, Scheduler::NotificationSetting.new( id: @other_person.id))).to be_truthy
      expect(can?(:update, Scheduler::NotificationSetting.new( id: @other_person.id))).to be_truthy
    end

    it "can't read and update other shift territory person's notification setting" do
      expect(cannot?(:read, Scheduler::NotificationSetting.new( id: @non_shift_territory_person.id))).to be_truthy
      expect(cannot?(:update, Scheduler::NotificationSetting.new( id: @non_shift_territory_person.id))).to be_truthy
    end

    it "can read and update shift territory person's flex schedule" do
      expect(can?(:read, Scheduler::FlexSchedule.new( id: @other_person.id))).to be_truthy
      expect(can?(:update, Scheduler::FlexSchedule.new( id: @other_person.id))).to be_truthy
    end

    it "can't read and update other shift territory person's flex schedule" do
      expect(cannot?(:read, Scheduler::FlexSchedule.new( id: @non_shift_territory_person.id))).to be_truthy
      expect(cannot?(:update, Scheduler::FlexSchedule.new( id: @non_shift_territory_person.id))).to be_truthy
    end

    it "can manage own shift territory's shifts" do
      shift = Scheduler::Shift.new shift_territory_id: @person.shift_territory_ids.first

      expect(can?(:read, shift)).to be_truthy
      expect(can?(:update, shift)).to be_truthy
      expect(can?(:update_shifts, shift)).to be_truthy
    end

    it "can't manage other shift territory's shifts" do
      shift = Scheduler::Shift.new shift_territory_id: @non_shift_territory_person.shift_territory_ids.first

      expect(cannot?(:read, shift)).to be_truthy
      expect(cannot?(:update, shift)).to be_truthy
      expect(cannot?(:update_shifts, shift)).to be_truthy
    end

    it "can get admin notifications only on own setting" do
      expect(can?(:receive_admin_notifications, Scheduler::NotificationSetting.new( id: @person.id))).to be_truthy
      expect(cannot?(:receive_admin_notifications, Scheduler::NotificationSetting.new( id: @other_person.id))).to be_truthy
    end
  end
end


