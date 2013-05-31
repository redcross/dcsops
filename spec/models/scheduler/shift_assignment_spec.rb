require 'spec_helper'

describe Scheduler::ShiftAssignment do

  before :each do
    @chapter = FactoryGirl.create :chapter
    @group = FactoryGirl.create :shift_group, chapter: @chapter, start_offset: 10.hours, end_offset: 22.hours
    @counties = @positions = (1..2).map{|i| FactoryGirl.create :county, name: "County #{i}", chapter: @chapter}
    @positions = (1..2).map{|i| FactoryGirl.create :position, name: "Position #{i}"}
    @shifts = (1..2).map{|i| FactoryGirl.create :shift, shift_group: @group, name: "Shift #{i}", positions: [@positions[i-1]], county: @counties[i-1]}

    @person= FactoryGirl.create :person, positions: [@positions.first], counties: [@counties.first]
  end

  let(:zone) {@chapter.time_zone}

  it "should be createable and destroyable" do
    item = Scheduler::ShiftAssignment.create! person: @person, shift: @shifts.first, date: Date.today

    item.destroy.should be_true
  end
  #describe "should require a person, shift, and date" do
  it { should validate_presence_of(:person) }
  it { should validate_presence_of(:shift) }
  it { should validate_presence_of(:date) }
  #end
  it "should validate that a person is allowed to take the shift" do
    item = Scheduler::ShiftAssignment.new person: @person, shift: @shifts.first, date: Date.today
    item.should be_valid

    item = Scheduler::ShiftAssignment.new person: @person, shift: @shifts.second, date: Date.today
    item.should_not be_valid
    item.errors[:shift].to_s.should include "not allowed to take this shift"
  end

  it "should prevent a person from taking multiple shifts in the same group in the same day" do
    item = Scheduler::ShiftAssignment.create! person: @person, shift: @shifts.first, date: Date.today

    @person.positions = @positions; @person.counties = @counties; @person.save

    item = Scheduler::ShiftAssignment.new person: @person, shift: @shifts.first, date: Date.today
    item.should_not be_valid
    item.errors[:shift].to_s.should include "already signed up"
  end

  it "should allow a person to have multiple shifts in a day" do
    second_group = FactoryGirl.create :shift_group, name: "Group 2", chapter: @group.chapter
    second_shift = FactoryGirl.create :shift, county: @person.counties.first, positions: [@positions.first], shift_group: second_group

    item = Scheduler::ShiftAssignment.create person: @person, shift: @shifts.first, date: Date.today
    item.should be_valid

    item = Scheduler::ShiftAssignment.create person: @person, shift: second_shift, date: Date.today
    item.should be_valid
  end

  it "should validate that the shift is not full with max_signups=1" do
    @person2 = FactoryGirl.create :person, positions: [@positions.first], counties: [@counties.first]

    item = Scheduler::ShiftAssignment.create person: @person, shift: @shifts.first, date: Date.today
    item.should be_valid

    item = Scheduler::ShiftAssignment.create person: @person2, shift: @shifts.first, date: Date.today
    item.should_not be_valid
  end

  it "should validate that the shift is not full with max_signups=2" do
    @person2 = FactoryGirl.create :person, positions: [@positions.first], counties: [@counties.first]
    @person3 = FactoryGirl.create :person, positions: [@positions.first], counties: [@counties.first]

    @shifts.first.tap{|s| s.max_signups = 2; s.save}

    item = Scheduler::ShiftAssignment.create person: @person, shift: @shifts.first, date: Date.today
    item.should be_valid

    item = Scheduler::ShiftAssignment.create person: @person2, shift: @shifts.first, date: Date.today
    item.should be_valid

    item = Scheduler::ShiftAssignment.create person: @person3, shift: @shifts.first, date: Date.today
    item.should_not be_valid
  end

  it "should validate that the shift is not full with max_signups=0" do
    @person2 = FactoryGirl.create :person, positions: [@positions.first], counties: [@counties.first]
    @person3 = FactoryGirl.create :person, positions: [@positions.first], counties: [@counties.first]

    @shifts.first.tap{|s| s.max_signups = 0; s.save}

    item = Scheduler::ShiftAssignment.create person: @person, shift: @shifts.first, date: Date.today
    item.should be_valid

    item = Scheduler::ShiftAssignment.create person: @person2, shift: @shifts.first, date: Date.today
    item.should be_valid

    item = Scheduler::ShiftAssignment.create person: @person3, shift: @shifts.first, date: Date.today
    item.should be_valid
  end

  it "should not allow signups outside of the valid dates" do
    shift = @shifts.first

    item = Scheduler::ShiftAssignment.create person: @person, shift: shift, date: Date.today
    item.should be_valid

    shift.shift_begins = Date.tomorrow; shift.save

    item = Scheduler::ShiftAssignment.create person: @person, shift: shift, date: Date.today
    item.should_not be_valid

    shift.shift_begins = nil; shift.shift_ends = Date.yesterday; shift.save

    item = Scheduler::ShiftAssignment.create person: @person, shift: shift, date: Date.today
    item.should_not be_valid
  end

  it "should not allow cancellation before the frozen date" do
    shift = @shifts.first

    item = Scheduler::ShiftAssignment.create person: @person, shift: shift, date: Date.today
    item.should be_valid

    shift.signups_frozen_before = Date.tomorrow; shift.save

    item.destroy
    item.should_not be_destroyed
  end

  it "should not allow signup before the frozen date" do
    shift = @shifts.first

    shift.signups_frozen_before = Date.tomorrow; shift.save

    item = Scheduler::ShiftAssignment.create person: @person, shift: shift, date: zone.today
    item.should_not be_valid
  end


  describe "#swap" do
    it "should be swappable" do
      @person2 = FactoryGirl.create :person, positions: [@positions.first], counties: [@counties.first]

      shift = Scheduler::ShiftAssignment.create person: @person, shift: @shifts.first, date: zone.today.tomorrow
      new_record = shift.swap_to(@person2)

      new_record.should be_valid
      new_record.should_not be_changed
      shift.should be_destroyed
    end

    it "should not be swappable to someone who can't take the shift" do
      @person2 = FactoryGirl.create :person, positions: [], counties: []

      shift = Scheduler::ShiftAssignment.create person: @person, shift: @shifts.first, date: zone.today.tomorrow
      new_record = shift.swap_to(@person2)

      new_record.should_not be_valid
      new_record.should be_new_record
      shift.should_not be_destroyed
    end

    it "should allow swaps before the frozen date" do
      @person2 = FactoryGirl.create :person, positions: [@positions.first], counties: [@counties.first]
      shift = @shifts.first

      ass = Scheduler::ShiftAssignment.create person: @person, shift: shift, date: zone.today.tomorrow
      shift.signups_frozen_before = Date.today + 4; shift.save

      new_record = ass.swap_to(@person2)

      new_record.should be_valid
      new_record.should_not be_changed
      ass.should be_destroyed
    end
  end

  describe "notification scopes" do
    after(:each) {back_to_1985}

    before(:each) do
      @prefs = Scheduler::NotificationSetting.create id: @person.id
    end

    describe "needs_email_invite" do
      before(:each) do
        @prefs.update_attribute :send_email_invites, true
        @item = Scheduler::ShiftAssignment.create person: @person, shift: @shifts.first, date: Date.tomorrow
      end

      it "should want to send an invite" do
        Scheduler::ShiftAssignment.needs_email_invite.should =~ [@item]
      end

      it "should not want to send an invite if the invite has been sent" do
        @item.update_attribute :email_invite_sent, true
        Scheduler::ShiftAssignment.needs_email_invite.should =~ []
      end

      it "should not send the invite if the shift has already passed" do
        Delorean.time_travel_to "1 day from now"
        Scheduler::ShiftAssignment.needs_email_invite.should =~ []
      end

    end

    describe "needs_email_reminder" do
      before(:each) do
        @prefs.update_attribute :email_advance_hours, 7200 # 2 hours ahead of time
        @item = Scheduler::ShiftAssignment.create person: @person, shift: @shifts.first, date: zone.today.tomorrow
      end

      it "should not want to send the reminder ahead of time" do
        Scheduler::ShiftAssignment.needs_email_reminder(@chapter).should =~ []
      end

      it "should want to send the reminder during the window" do
        Delorean.time_travel_to zone.today.tomorrow.in_time_zone(zone).advance seconds: 9.hours
        Scheduler::ShiftAssignment.needs_email_reminder(@chapter).should =~ [@item]
      end

      it "should not want to send an invite if the invite has been sent" do
        Delorean.time_travel_to zone.today.tomorrow.in_time_zone(zone).advance seconds: 9.hours
        @item.update_attribute :email_reminder_sent, true
        Scheduler::ShiftAssignment.needs_email_reminder(@chapter).should =~ []
      end

      it "should not send the invite if the shift has already passed" do
        Delorean.time_travel_to zone.today.tomorrow.in_time_zone(zone).advance seconds: 23.hours
        Scheduler::ShiftAssignment.needs_email_reminder(@chapter).should =~ []
      end

    end

    describe "needs_sms_reminder" do
      before(:each) do
        @prefs.update_attribute :sms_advance_hours, 2.hours # 2 hours ahead of time
        @item = Scheduler::ShiftAssignment.create person: @person, shift: @shifts.first, date: zone.today.tomorrow
      end

      it "should not want to send the reminder ahead of time" do
        Scheduler::ShiftAssignment.needs_sms_reminder(@chapter).should =~ []
      end

      it "should want to send the reminder during the window" do
        Delorean.time_travel_to zone.today.tomorrow.in_time_zone(zone).advance seconds: 9.hours
        Scheduler::ShiftAssignment.needs_sms_reminder(@chapter).should =~ [@item]
      end

      it "should not want to send an invite if the invite has been sent" do
        Delorean.time_travel_to zone.today.tomorrow.in_time_zone(zone).advance seconds: 9.hours
        @item.update_attribute :sms_reminder_sent, true
        Scheduler::ShiftAssignment.needs_sms_reminder(@chapter).should =~ []
      end

      it "should not send the invite if the shift has already passed" do
        Delorean.time_travel_to zone.today.tomorrow.in_time_zone(zone).advance seconds: 23.hours
        Scheduler::ShiftAssignment.needs_sms_reminder(@chapter).should =~ []
      end

      it "should not send the invite if we are outside the sms window" do
        @prefs.update_attribute :sms_only_after, 8.hours # send texts only after noon

        Delorean.time_travel_to zone.today.tomorrow.in_time_zone(zone).advance seconds: 7.hours
        Scheduler::ShiftAssignment.needs_sms_reminder(@chapter).should =~ []

        Delorean.time_travel_to @chapter.time_zone.now.change hour: 9
        Scheduler::ShiftAssignment.needs_sms_reminder(@chapter).should =~ [@item]
      end

      it "should send the invite once we are in the window" do
        @prefs.update_attribute :sms_only_after, 12.hours # send texts only after noon

        Delorean.time_travel_to zone.today.tomorrow.in_time_zone(zone).advance seconds: 9.hours
        Scheduler::ShiftAssignment.needs_sms_reminder(@chapter).should =~ []

        Delorean.time_travel_to zone.now.change hour: 13
        Scheduler::ShiftAssignment.needs_sms_reminder(@chapter).should =~ [@item]
      end

    end
  end
end