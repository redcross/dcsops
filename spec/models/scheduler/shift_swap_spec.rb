require 'spec_helper'

describe Scheduler::ShiftSwap do

  let(:delegate) { double :auth_delegate, can?: true }
  let(:shift) { FactoryGirl.create :shift_with_positions}
  let(:person) { FactoryGirl.create :person, chapter: shift.county.chapter, positions: shift.positions, counties: [shift.county]}
  let(:other_person) { FactoryGirl.create :person, chapter: shift.county.chapter, positions: shift.positions, counties: [shift.county]}
  let(:assignment) { FactoryGirl.create :shift_assignment, person: person, date: Date.current, shift: shift, shift_group: shift.shift_groups.first}

  let(:swap) { Scheduler::ShiftSwap.new(assignment, delegate) }

  it "can be created" do
    Scheduler::ShiftSwap.new(assignment, delegate)
  end

  it "can request a swap with no designee" do
    expect {
      swap.request_swap!
    }.to change{assignment.reload.available_for_swap}.to(true)
  end

  it "can request a swap with a designee" do
    expect {
      swap.request_swap! other_person
    }.to change{assignment.reload.available_for_swap}.to(true)
  end

  context "with an existing request" do
    before(:each) {assignment.update_attribute :available_for_swap, true}

    it "can cancel a swap" do
      expect {
        swap.cancel_swap!
      }.to change{assignment.reload.available_for_swap}.to(false)
    end

    it "can confirm a swap" do
      expect {
        config = Scheduler::DispatchConfig.new chapter: person.chapter, name: "Config"
        config.shift_first = shift
        config.save!

        Scheduler::SendDispatchRosterJob.should_receive(:enqueue).with(person.chapter, false)
        success = swap.confirm_swap! other_person
        success.should be_true
        swap.new_assignment.should_not be_nil
        swap.new_assignment.should be_persisted
      }.to_not change{Scheduler::ShiftAssignment.count}
      expect {
        assignment.reload
      }.to raise_exception(ActiveRecord::RecordNotFound)
    end

    it "confirms a swap even when the shift is frozen for the given day" do
      expect {
        shift.update_attribute :signups_frozen_before, assignment.date + 10
        success = swap.confirm_swap! other_person
        success.should be_true
      }.to_not change{Scheduler::ShiftAssignment.count}
    end

    it "rejects a swap between the same person" do
      success = swap.confirm_swap! person
      success.should be_false
      swap.new_assignment.should_not be_persisted
      expect {
        assignment.reload
      }.to_not raise_exception
      swap.error_message.should include('swap a shift to yourself')
    end

    it "rejects a swap if the auth delegate returns false" do
      delegate.stub can?: false
      success = swap.confirm_swap! person
      success.should be_false
    end

    it "rejects a swap if the shift is otherwise invalid" do
      other_person.position_ids = []
      other_person.save!
      success = swap.confirm_swap! other_person
      success.should be_false
    end

  end

end