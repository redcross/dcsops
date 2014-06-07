require 'spec_helper'

describe Scheduler::SendDispatchRosterJob do
  let(:chapter) { person.chapter }
  let(:shift) { FactoryGirl.create :shift_with_positions, dispatch_role: 1 }
  let(:person) { FactoryGirl.create :person, chapter: shift.county.chapter, positions: shift.positions, counties: [shift.county]}
  let(:assignment) { FactoryGirl.create :shift_assignment, date: Date.today, person: person, shift: shift }

  subject { Scheduler::SendDispatchRosterJob.new chapter }

  describe "#perform" do
    it "should run if force is given" do
      job = Scheduler::SendDispatchRosterJob.new(chapter, true)
      job.should_receive :run!
      job.perform
    end

    it "should run if there are shifts needing update" do
      job = Scheduler::SendDispatchRosterJob.new(chapter, false)
      job.should_receive :run!
      job.should_receive(:shifts_needing_update?).and_return(true)
      job.perform
    end

    it "should not run otherwise" do
      job = Scheduler::SendDispatchRosterJob.new(chapter, false)
      job.should_not_receive :run!
      job.should_receive(:shifts_needing_update?).and_return(false)
      job.perform
    end

    it "should mark assignments as synced" do
      expect{
        job = Scheduler::SendDispatchRosterJob.new(chapter, true)
        job.should_receive :run!
        job.perform
      }.to change{assignment.reload.synced}.from(false).to(true)
    end
  end

  describe '#run!' do
    it "should call the mailer" do
      delivery = double(:delivery)
      delivery.should_receive(:deliver).and_return(true)
      Scheduler::DirectlineMailer.should_receive(:export).with(chapter, Date.current-1, Date.current+60).and_return(delivery)
      subject.run!
    end
  end

  describe "#shifts_needing_update?" do

    it "should be true if there are unsynced shifts in the near future" do
      assignment
      subject.shifts_needing_update?.should be_true
    end

    it "should be false if there aren't unsynced shifts" do
      assignment.update_attribute :synced, true
      subject.shifts_needing_update?.should be_false
    end

    it "should be false if there are unsynced shifts in the distant future" do
      assignment.update_attribute :date, Date.today+4
      subject.shifts_needing_update?.should be_false
    end

    it "should ignore non-dispatch shifts" do
      shift.update_attribute :dispatch_role, nil
      subject.shifts_needing_update?.should be_false
    end
  end
end