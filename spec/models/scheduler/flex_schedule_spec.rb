require 'spec_helper'

describe Scheduler::FlexSchedule do
  let(:schedule) { Scheduler::FlexSchedule.new }

  it "responds to available" do
    schedule.available("tuesday", "night").should be_false
    schedule.available_tuesday_night = true
    schedule.available("tuesday", "night").should be_true
  end

  it "counts its shifts" do
    schedule.num_shifts.should == 0
    schedule.available_tuesday_night = true
    schedule.num_shifts.should == 1
  end

  it "#by_distance_from sorts by distance" do
    f = FactoryGirl.create :flex_schedule
    inc = double :location, lat: 0, lng: 0
    Scheduler::FlexSchedule.by_distance_from(inc).should == [f]
  end
end