require 'spec_helper'

describe Scheduler::SendDispatchRosterJob do
  let(:region) { person.region }
  let(:shift) { FactoryGirl.create :shift_with_positions }
  let!(:config) { Scheduler::DispatchConfig.create! name: 'Config', region: region, shift_first: shift, is_active: true }
  let(:person) { FactoryGirl.create :person, region: shift.county.region, positions: shift.positions, counties: [shift.county]}
  let(:assignment) { FactoryGirl.create :shift_assignment, date: Date.today, person: person, shift: shift }

  subject { Scheduler::SendDispatchRosterJob.new region }

  describe "#perform" do
    it "should run if force is given" do
      job = Scheduler::SendDispatchRosterJob.new(region, true)
      expect(job).to receive :run!
      job.perform
    end

    it "should run if there are shifts needing update" do
      job = Scheduler::SendDispatchRosterJob.new(region, false)
      expect(job).to receive :run!
      expect(job).to receive(:shifts_needing_update?).and_return(true)
      job.perform
    end

    it "should not run otherwise" do
      job = Scheduler::SendDispatchRosterJob.new(region, false)
      expect(job).not_to receive :run!
      expect(job).to receive(:shifts_needing_update?).and_return(false)
      job.perform
    end

    it "should mark assignments as synced" do
      expect{
        job = Scheduler::SendDispatchRosterJob.new(region, true)
        expect(job).to receive :run!
        job.perform
      }.to change{assignment.reload.synced}.from(false).to(true)
    end
  end

  describe '#run!' do
    it "should call the mailer" do
      delivery = double(:delivery)
      expect(delivery).to receive(:deliver).and_return(true)
      expect(Scheduler::DirectlineMailer).to receive(:export).with(region, region.time_zone.today-1, region.time_zone.today+15).and_return(delivery)
      subject.run!
    end
  end

  describe "#shifts_needing_update?" do

    it "should be true if there are unsynced shifts in the near future" do
      assignment
      expect(subject.shifts_needing_update?).to be_truthy
    end

    it "should be false if there aren't unsynced shifts" do
      assignment.update_attribute :synced, true
      expect(subject.shifts_needing_update?).to be_falsey
    end

    it "should be false if there are unsynced shifts in the distant future" do
      assignment.update_attribute :date, Date.today+4
      expect(subject.shifts_needing_update?).to be_falsey
    end

    it "should ignore non-dispatch shifts" do
      config.update_attribute :shift_first_id, nil
      expect(subject.shifts_needing_update?).to be_falsey
    end
  end
end