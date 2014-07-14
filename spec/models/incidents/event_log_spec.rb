require 'spec_helper'

describe Incidents::EventLog, :type => :model do
  describe "handles times gracefully" do
    it "with ISO format" do
      subject.event_time = "2014-05-28 18:35"
      expect(subject.event_time).to eq(Time.zone.parse("2014-05-28 18:35"))
    end
    it "with m/d/y format" do
      subject.event_time = "05/28/2014 18:35"
      expect(subject.event_time).to eq(Time.zone.parse("2014-05-28 18:35"))
    end
    it "with invalid format" do
      subject.event_time = "pm"
      expect(subject.event_time).to eq(nil)
    end
  end
end
