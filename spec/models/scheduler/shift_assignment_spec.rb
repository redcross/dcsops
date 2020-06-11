require 'spec_helper'

describe Scheduler::ShiftAssignment, :type => :model do

  let(:region) { FactoryGirl.create :region }
  let(:group) { FactoryGirl.create :shift_group, region: region, start_offset: 10.hours, end_offset: 22.hours }
  let(:counties) { (1..2).map{|i| FactoryGirl.create :county, name: "County #{i}", region: region} }
  let(:positions) { (1..2).map{|i| FactoryGirl.create :position, name: "Position #{i}", region: region} }

  let(:first_shift) { FactoryGirl.create :shift, shift_groups: [group], name: "Shift 1", positions: [positions.first], county: counties.first }
  let(:second_shift) { FactoryGirl.create :shift, shift_groups: [group], name: "Shift 2", positions: [positions.last], county: counties.last }

  let(:person) { FactoryGirl.create :person, region: region, positions: [positions.first], counties: [counties.first] }

  let(:zone) {region.time_zone}

  it "should be createable and destroyable" do
    item = Scheduler::ShiftAssignment.create! person: person, shift: first_shift, date: Date.today, shift_group: group
    expect(item).to be_persisted
    expect(item.destroy).to be_truthy
  end
  #describe "should require a person, shift, and date" do
  it { is_expected.to validate_presence_of(:person) }
  it { is_expected.to validate_presence_of(:shift) }
  it { is_expected.to validate_presence_of(:date) }
  #end
  it "should validate that a person is allowed to take the shift" do
    item = Scheduler::ShiftAssignment.new person: person, shift: first_shift, date: Date.today, shift_group: group
    expect(item).to be_valid

    item = Scheduler::ShiftAssignment.new person: person, shift: second_shift, date: Date.today, shift_group: group
    expect(item).not_to be_valid
    expect(item.errors[:shift].to_s).to include "not allowed to take this shift"
  end

  it "should allow a person from a different county if ignore_county=true" do
    first_shift.update_attribute :county, counties.second

    first_shift.update_attribute :ignore_county, true
    item = Scheduler::ShiftAssignment.new person: person, shift: first_shift, date: Date.today, shift_group: group
    expect(item).to be_valid
  end

  context "checking multiple shifts in the same group" do
    before :each do
      person.positions = positions; person.counties = counties; person.save
    end

    it "should prevent a person from taking multiple shifts in the same group in the same day" do
      item = Scheduler::ShiftAssignment.create! person: person, shift: first_shift, date: Date.today, shift_group: group

      item = Scheduler::ShiftAssignment.new person: person, shift: first_shift, date: Date.today, shift_group: group
      expect(item).not_to be_valid
      expect(item.errors[:shift].to_s).to include "already signed up"
    end

    it "should allow a person to take the same shift in different groups in the same day" do
      second_group = FactoryGirl.create :shift_group, region: group.region
      first_shift.shift_groups += [second_group]
      first_shift.save

      item = Scheduler::ShiftAssignment.create! person: person, shift: first_shift, date: Date.today, shift_group: group
      item = Scheduler::ShiftAssignment.new person: person, shift: first_shift, date: Date.today, shift_group: second_group
      expect(item).to be_valid
    end

    it "should allow a person to take multiple shifts if the new shift is not exclusive" do
      item = Scheduler::ShiftAssignment.create! person: person, shift: first_shift, date: Date.today, shift_group: group

      second_shift.update_attribute :exclusive, false
      item = Scheduler::ShiftAssignment.new person: person, shift: second_shift, date: Date.today, shift_group: group
      expect(item).to be_valid
    end
    it "should allow a person to take multiple shifts if the other shift is not exclusive" do
      first_shift.update_attribute :exclusive, false
      item = Scheduler::ShiftAssignment.create! person: person, shift: first_shift, date: Date.today, shift_group: group

      item = Scheduler::ShiftAssignment.new person: person, shift: second_shift, date: Date.today, shift_group: group
      expect(item).to be_valid
    end
  end

  it "should allow a person to have multiple shifts in a day" do
    second_group = FactoryGirl.create :shift_group, name: "Group 2", region: group.region
    second_shift = FactoryGirl.create :shift, county: person.counties.first, positions: [positions.first], shift_groups: [second_group]

    item = Scheduler::ShiftAssignment.create person: person, shift: first_shift, date: Date.today, shift_group: group
    expect(item).to be_valid

    item = Scheduler::ShiftAssignment.create person: person, shift: second_shift, date: Date.today, shift_group: second_group
    expect(item).to be_valid
  end

  it "should validate that the shift is not full with max_signups=1" do
    person2 = FactoryGirl.create :person, region: region,  positions: [positions.first], counties: [counties.first]

    item = Scheduler::ShiftAssignment.create person: person, shift: first_shift, date: Date.today, shift_group: group
    expect(item).to be_valid

    item = Scheduler::ShiftAssignment.create person: person2, shift: first_shift, date: Date.today, shift_group: group
    expect(item).not_to be_valid
  end

  it "should validate that the shift is not full with max_signups=2" do
    person2 = FactoryGirl.create :person, region: region,  positions: [positions.first], counties: [counties.first]
    person3 = FactoryGirl.create :person, region: region,  positions: [positions.first], counties: [counties.first]

    first_shift.tap{|s| s.max_signups = 2; s.save}

    item = Scheduler::ShiftAssignment.create person: person, shift: first_shift, date: Date.today, shift_group: group
    expect(item).to be_valid

    item = Scheduler::ShiftAssignment.create person: person2, shift: first_shift, date: Date.today, shift_group: group
    expect(item).to be_valid

    item = Scheduler::ShiftAssignment.create person: person3, shift: first_shift, date: Date.today, shift_group: group
    expect(item).not_to be_valid
  end

  it "should validate that the shift is not full with max_signups=0" do
    person2 = FactoryGirl.create :person, region: region,  positions: [positions.first], counties: [counties.first]
    person3 = FactoryGirl.create :person, region: region,  positions: [positions.first], counties: [counties.first]

    first_shift.tap{|s| s.max_signups = 0; s.save}

    item = Scheduler::ShiftAssignment.create person: person, shift: first_shift, date: Date.today, shift_group: group
    expect(item).to be_valid

    item = Scheduler::ShiftAssignment.create person: person2, shift: first_shift, date: Date.today, shift_group: group
    expect(item).to be_valid

    item = Scheduler::ShiftAssignment.create person: person3, shift: first_shift, date: Date.today, shift_group: group
    expect(item).to be_valid
  end

  it "should not allow signups outside of the valid dates" do
    shift = first_shift

    item = Scheduler::ShiftAssignment.create person: person, shift: shift, date: Date.today, shift_group: group
    expect(item).to be_valid

    shift.shift_begins = Date.tomorrow; shift.save

    item = Scheduler::ShiftAssignment.create person: person, shift: shift, date: Date.today, shift_group: group
    expect(item).not_to be_valid

    shift.shift_begins = nil; shift.shift_ends = Date.yesterday; shift.save

    item = Scheduler::ShiftAssignment.create person: person, shift: shift, date: Date.today, shift_group: group
    expect(item).not_to be_valid
  end

  it "should not allow cancellation before the frozen date" do
    shift = first_shift

    item = Scheduler::ShiftAssignment.create person: person, shift: shift, date: zone.today, shift_group: group
    expect(item).to be_valid

    shift.signups_frozen_before = zone.today.tomorrow; shift.save

    item.destroy
    expect(item).not_to be_destroyed
  end

  it "should not allow signup before the frozen date" do
    shift = first_shift

    shift.signups_frozen_before = zone.today.tomorrow; shift.save

    item = Scheduler::ShiftAssignment.create person: person, shift: shift, date: zone.today, shift_group: group
    expect(item).not_to be_valid
  end

  describe "notification scopes" do
    after(:each) {back_to_1985}

    before(:each) do
      @prefs = Scheduler::NotificationSetting.create id: person.id
    end

    describe "needs_email_invite" do
      before(:each) do
        @prefs.update_attribute :send_email_invites, true
        @item = Scheduler::ShiftAssignment.create person: person, shift: first_shift, date: zone.today.tomorrow, shift_group: group
      end

      it "should want to send an invite" do
        expect(Scheduler::ShiftAssignment.needs_email_invite(region)).to match_array([@item])
      end

      it "should not want to send an invite if the invite has been sent" do
        @item.update_attribute :email_invite_sent, true
        expect(Scheduler::ShiftAssignment.needs_email_invite(region)).to match_array([])
      end

      it "should not send the invite if the shift has already passed" do
        Delorean.time_travel_to "2 days from now"
        expect(Scheduler::ShiftAssignment.needs_email_invite(region)).to match_array([])
      end

    end

    describe "needs_email_reminder" do
      before(:each) do
        @prefs.update_attribute :email_advance_hours, 7200 # 2 hours ahead of time
        @item = Scheduler::ShiftAssignment.create person: person, shift: first_shift, date: zone.today.tomorrow, shift_group: group
      end

      it "should not want to send the reminder ahead of time" do
        expect(Scheduler::ShiftAssignment.needs_email_reminder(region)).to match_array([])
      end

      it "should want to send the reminder during the window" do
        Delorean.time_travel_to zone.today.tomorrow.in_time_zone(zone).advance seconds: 9.hours
        expect(Scheduler::ShiftAssignment.needs_email_reminder(region)).to match_array([@item])
      end

      it "should not want to send an invite if the invite has been sent" do
        Delorean.time_travel_to zone.today.tomorrow.in_time_zone(zone).advance seconds: 9.hours
        @item.update_attribute :email_reminder_sent, true
        expect(Scheduler::ShiftAssignment.needs_email_reminder(region)).to match_array([])
      end

      it "should not send the invite if the shift has already passed" do
        Delorean.time_travel_to zone.today.tomorrow.in_time_zone(zone).advance seconds: 23.hours
        expect(Scheduler::ShiftAssignment.needs_email_reminder(region)).to match_array([])
      end

    end

    describe "needs_sms_reminder" do
      before(:each) do
        @prefs.update_attribute :sms_advance_hours, 2.hours # 2 hours ahead of time
        @item = Scheduler::ShiftAssignment.create person: person, shift: first_shift, date: zone.today.tomorrow, shift_group: group
      
        person.cell_phone_carrier = Roster::CellCarrier.create name: 'Test', sms_gateway: '@example.com'
        person.cell_phone = Faker::PhoneNumber.phone_number
        person.save
      end

      it "should not want to send the reminder ahead of time" do
        expect(Scheduler::ShiftAssignment.needs_sms_reminder(region)).to match_array([])
      end

      it "should want to send the reminder during the window" do
        Delorean.time_travel_to zone.today.tomorrow.in_time_zone(zone).advance seconds: 9.hours
        expect(Scheduler::ShiftAssignment.needs_sms_reminder(region)).to match_array([@item])
      end

      it "should not want to send an invite if the invite has been sent" do
        Delorean.time_travel_to zone.today.tomorrow.in_time_zone(zone).advance seconds: 9.hours
        @item.update_attribute :sms_reminder_sent, true
        expect(Scheduler::ShiftAssignment.needs_sms_reminder(region)).to match_array([])
      end

      it "should not send the invite if the shift has already passed" do
        Delorean.time_travel_to zone.today.tomorrow.in_time_zone(zone).advance seconds: 23.hours
        expect(Scheduler::ShiftAssignment.needs_sms_reminder(region)).to match_array([])
      end

      it "should not send the invite if we are outside the sms window" do
        @prefs.update_attribute :sms_only_after, 8.hours # send texts only after noon

        Delorean.time_travel_to zone.today.tomorrow.in_time_zone(zone).advance seconds: 7.hours
        expect(Scheduler::ShiftAssignment.needs_sms_reminder(region)).to match_array([])

        Delorean.time_travel_to region.time_zone.now.change hour: 9
        expect(Scheduler::ShiftAssignment.needs_sms_reminder(region)).to match_array([@item])
      end

      it "should send the invite once we are in the window" do
        @prefs.update_attribute :sms_only_after, 12.hours # send texts only after noon

        Delorean.time_travel_to zone.today.tomorrow.in_time_zone(zone).advance seconds: 9.hours
        expect(Scheduler::ShiftAssignment.needs_sms_reminder(region)).to match_array([])

        Delorean.time_travel_to zone.now.change hour: 13
        expect(Scheduler::ShiftAssignment.needs_sms_reminder(region)).to match_array([@item])
      end

    end
  end
end