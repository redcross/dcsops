require 'spec_helper'

describe Scheduler::Shift, :type => :model do
  let(:region) {FactoryGirl.create :region}
  let(:position) {FactoryGirl.create :position, region: region}
  let(:county) {FactoryGirl.create :county, region: region}
  let(:shift_time) {FactoryGirl.create :shift_time, region: region}
  let(:shift) {FactoryGirl.create :shift, shift_times: [shift_time], positions: [position], county: county}
  let(:date) {shift.county.region.time_zone.today}
  let(:person) { FactoryGirl.create :person, region: region, counties: [shift.county], positions: shift.positions}
      
  describe "can_be_taken_by?" do
    it "should be true for a person with the appropriate counties and shifts" do
      expect(shift.can_be_taken_by?(person)).to be_truthy
    end

    it "should be false for a person without the county" do
      person.counties = []; person.save
      expect(shift.can_be_taken_by?(person)).to be_falsey
    end

    it "should be false for a person without the position" do
      person.positions = []; person.save
      expect(shift.can_be_taken_by?(person)).to be_falsey
    end

    it "should be true when ignore_county is set" do
      person.counties = []; person.save
      shift.update_attribute :ignore_county, true
      expect(shift.can_be_taken_by?(person)).to be_truthy
    end
  end

  describe "can_sign_up_on_day" do
    it "should be true today" do
      expect(shift.can_sign_up_on_day(date, shift_time)).to be_truthy
    end

    it "should be true tomorrow" do
      expect(shift.can_sign_up_on_day(date+1, shift_time)).to be_truthy
    end

    it "should be false yesterday" do
      expect(shift.can_sign_up_on_day(date-1, shift_time)).to be_falsey
    end

    it "should be true yesterday if we are allowing signups in the past" do
      shift.stub allow_signup_in_past?: true
      expect(shift.can_sign_up_on_day(date-1, shift_time)).to be_truthy
    end

    it "should be false if the shift is not active" do
      shift.stub active_on_day?: false
      expect(shift.can_sign_up_on_day(date, shift_time)).to be_falsey
    end

    it "should be false if the shift has been frozen before" do
      shift.update_attribute :signups_frozen_before, date+1
      expect(shift.can_sign_up_on_day(date, shift_time)).to be_falsey
    end

    it "should be false if the shift has been frozen after" do
      shift.update_attribute :signups_available_before, date-1
      expect(shift.can_sign_up_on_day(date, shift_time)).to be_falsey
    end

    it "should be false if max_advance_signup is too soon" do
      shift.update_attribute :max_advance_signup, 10
      expect(shift.can_sign_up_on_day(date+20, shift_time)).to be_falsey
    end

    describe "with signups" do
      before(:each) do
        FactoryGirl.create :shift_assignment, person: person, shift: shift, date: date, shift_time: shift_time
      end

      it "should be true if max_signups=0" do
        shift.update_attribute :max_signups, 0
        expect(shift.can_sign_up_on_day(date, shift_time)).to be_truthy
      end

      it "should be false if max_signups=1" do
        shift.update_attribute :max_signups, 1
        expect(shift.can_sign_up_on_day(date, shift_time)).to be_falsey
      end

      it "should be false if max_signups=2" do
        shift.update_attribute :max_signups, 2
        expect(shift.can_sign_up_on_day(date, shift_time)).to be_truthy
      end
    end
  end

  describe "can_remove_on_day" do
    it "should be true today" do
      expect(shift.can_remove_on_day(date, shift_time)).to be_truthy
    end

    it "should be true tomorrow" do
      expect(shift.can_remove_on_day(date+1, shift_time)).to be_truthy
    end

    it "should be false yesterday" do
      expect(shift.can_remove_on_day(date-1, shift_time)).to be_falsey
    end

    it "should be false if the shift has been frozen before" do
      shift.update_attribute :signups_frozen_before, date+1
      expect(shift.can_remove_on_day(date, shift_time)).to be_falsey
    end

    it "should be false if the shift has been frozen after" do
      shift.update_attribute :signups_available_before, date-1
      expect(shift.can_remove_on_day(date, shift_time)).to be_falsey
    end

    it "should be false if the min_advance_signup has passed" do
      shift.update_attribute :min_advance_signup, 1
      expect(shift.can_remove_on_day(date, shift_time)).to be_falsey
      expect(shift.can_remove_on_day(date+1, shift_time)).to be_truthy
    end
  end

  describe "allow_signup_in_past" do
    it "can sign up if date is in the past but shift hasn't ended" do
      day = region.time_zone.today.day
      shift_time.update_attributes period: 'monthly', start_offset: 0, end_offset: 33
      expect(shift.can_sign_up_on_day(date-1, shift_time)).to be_truthy
    end
  end

  describe "active_on_day?" do
    it "should be false if the shift has not begun yet" do
      shift.update_attribute :shift_begins, date+1
      expect(shift.active_on_day?(date, shift_time)).to be_falsey
    end

    it "should be false if the shift has ended" do
      shift.update_attribute :shift_ends, date-1
      expect(shift.active_on_day?(date, shift_time)).to be_falsey
    end
  end
end
