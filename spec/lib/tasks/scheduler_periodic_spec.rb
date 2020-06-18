require 'spec_helper'

describe "" do
  include_context "rake"
  let(:task_name) { self.class.description }

  before(:each) do
    @region = FactoryGirl.create :region
    @person = FactoryGirl.create :person, region: @region
    @shift = FactoryGirl.create :shift, positions: @person.positions, shift_territory: @person.shift_territories.first
    @setting = Scheduler::NotificationSetting.create id: @person.id
  end

  describe "scheduler_periodic:send_daily_shift_swap" do
    before(:each) do
      @person2 = FactoryGirl.create :person, region: @region, positions: @person.positions, shift_territories: @person.shift_territories
      FactoryGirl.create :shift_assignment, shift: @shift, date: @region.time_zone.today, person: @person2, available_for_swap: true
      @setting.update_attribute :email_all_swaps_daily, true
    end

    it "should send a swap reminder to someone subscribed" do
      expect(Scheduler::RemindersMailer).to receive(:daily_swap_reminder).with(@setting).and_return(double deliver: true)
      subject.invoke
    end
  end

  describe "scheduler_periodic:send_dispatch_roster" do
    before(:each) do
      @region.update_attributes code: '05503', scheduler_dispatch_export_recipient: Faker::Internet.email
    end

    it "should trigger the mailer with no env" do
      expect(Scheduler::SendDispatchRosterJob).to receive(:new).with(@region, true).and_call_original
      expect_any_instance_of(Scheduler::SendDispatchRosterJob).to receive :perform
      subject.invoke
    end

    it "should trigger the mailer with IF_NEEDED=false and run the mailer with force=false" do
      allow(ENV).to receive(:[]).with("IF_NEEDED").and_return("true")
      expect(Scheduler::SendDispatchRosterJob).to receive(:new).with(@region, false).and_call_original
      expect_any_instance_of(Scheduler::SendDispatchRosterJob).to receive :perform
      subject.invoke
    end

    it "should work all the way through" do
      expect_any_instance_of(Scheduler::DirectlineMailer).to receive(:export).with(@region, anything, anything).and_return(double deliver: true)
      subject.invoke
    end
  end


end