require 'spec_helper'

describe Scheduler::Shift do
  let(:chapter) {FactoryGirl.create :chapter}
  let(:position) {FactoryGirl.create :position, chapter: chapter}
  let(:county) {FactoryGirl.create :county, chapter: chapter}
  let(:shift_group) {FactoryGirl.create :shift_group, chapter: chapter}
  let(:shift) {FactoryGirl.create :shift, shift_group: shift_group, positions: [position], county: county}
  let(:date) {shift.shift_group.chapter.time_zone.today}
  let(:person) { FactoryGirl.create :person, chapter: chapter, counties: [shift.county], positions: shift.positions}
      
  describe "can_be_taken_by?" do
    it "should be true for a person with the appropriate counties and shifts" do
      shift.can_be_taken_by?(person).should be_true
    end

    it "should be false for a person without the county" do
      person.counties = []; person.save
      shift.can_be_taken_by?(person).should be_false
    end

    it "should be false for a person without the position" do
      person.positions = []; person.save
      shift.can_be_taken_by?(person).should be_false
    end

    it "should be true when ignore_county is set" do
      person.counties = []; person.save
      shift.update_attribute :ignore_county, true
      shift.can_be_taken_by?(person).should be_true
    end
  end

  describe "can_sign_up_on_day" do
    it "should be true today" do
      shift.can_sign_up_on_day(date).should be_true
    end

    it "should be true tomorrow" do
      shift.can_sign_up_on_day(date+1).should be_true
    end

    it "should be false yesterday" do
      shift.can_sign_up_on_day(date-1).should be_false
    end

    it "should be true yesterday if we are allowing signups in the past" do
      shift.stub allow_signup_in_past?: true
      shift.can_sign_up_on_day(date-1).should be_true
    end

    it "should be false if the shift is not active" do
      shift.stub active_on_day?: false
      shift.can_sign_up_on_day(date).should be_false
    end

    it "should be false if the shift has been frozen before" do
      shift.update_attribute :signups_frozen_before, date+1
      shift.can_sign_up_on_day(date).should be_false
    end

    it "should be false if the shift has been frozen after" do
      shift.update_attribute :signups_available_before, date-1
      shift.can_sign_up_on_day(date).should be_false
    end

    it "should be false if max_advance_signup is too soon" do
      shift.update_attribute :max_advance_signup, 10
      shift.can_sign_up_on_day(date+20).should be_false
    end

    describe "with signups" do
      before(:each) do
        FactoryGirl.create :shift_assignment, person: person, shift: shift, date: date
      end

      it "should be true if max_signups=0" do
        shift.update_attribute :max_signups, 0
        shift.can_sign_up_on_day(date).should be_true
      end

      it "should be false if max_signups=1" do
        shift.update_attribute :max_signups, 1
        shift.can_sign_up_on_day(date).should be_false
      end

      it "should be false if max_signups=2" do
        shift.update_attribute :max_signups, 2
        shift.can_sign_up_on_day(date).should be_true
      end
    end
  end

  describe "can_remove_on_day" do
    it "should be true today" do
      shift.can_remove_on_day(date).should be_true
    end

    it "should be true tomorrow" do
      shift.can_remove_on_day(date+1).should be_true
    end

    it "should be false yesterday" do
      shift.can_remove_on_day(date-1).should be_false
    end

    it "should be false if the shift has been frozen before" do
      shift.update_attribute :signups_frozen_before, date+1
      shift.can_sign_up_on_day(date).should be_false
    end

    it "should be false if the shift has been frozen after" do
      shift.update_attribute :signups_available_before, date-1
      shift.can_sign_up_on_day(date).should be_false
    end
  end

  describe "allow_signup_in_past" do
    it "can sign up if date is in the past but shift hasn't ended" do
      day = chapter.time_zone.today.day
      shift_group.update_attributes period: 'monthly', start_offset: 0, end_offset: 33
      shift.can_sign_up_on_day(date-1).should be_true
    end
  end

  describe "active_on_day?" do
    it "should be false if the shift has not begun yet" do
      shift.update_attribute :shift_begins, date+1
      shift.active_on_day?(date).should be_false
    end

    it "should be false if the shift has ended" do
      shift.update_attribute :shift_ends, date-1
      shift.active_on_day?(date).should be_false
    end
  end
end
