require 'spec_helper'

describe Scheduler::FlexSchedule, :type => :model do
  let(:schedule) { Scheduler::FlexSchedule.new }

  it "responds to available" do
    expect(schedule.available("tuesday", "night")).to be_falsey
    schedule.available_tuesday_night = true
    expect(schedule.available("tuesday", "night")).to be_truthy
  end

  it "counts its shifts" do
    expect(schedule.num_shifts).to eq(0)
    schedule.available_tuesday_night = true
    expect(schedule.num_shifts).to eq(1)
  end

  it "#by_distance_from sorts by distance" do
    f = FactoryGirl.create :flex_schedule
    inc = double :location, lat: 0, lng: 0
    expect(Scheduler::FlexSchedule.by_distance_from(inc)).to eq([f])
  end
end