require 'spec_helper'

describe Incidents::IncidentNumberSequence do

  let!(:chapter) { FactoryGirl.create :chapter, incidents_sequence_number: 100, incidents_sequence_year: '2014', incidents_sequence_format: "%<fy_short>02d-%<number>04d" }
  let!(:sequence) { Incidents::IncidentNumberSequence.new chapter }

  before(:each) {
    Delorean.time_travel_to '2013-07-02'
  }
  after(:each) {
    Delorean.back_to_the_present
  }

  it "generates a sequence number" do
    expect(sequence.next_sequence!).to eq('14-0101')
  end

  it "generates a sequence number according to the format" do
    chapter.update_attributes incidents_sequence_format: "%<fy>02d-%<number>03d"
    expect(sequence.next_sequence!).to eq('2014-101')
  end

  it "increments the stored sequence" do
    expect{
      expect(sequence.next_sequence!).to eq('14-0101')
    }.to change{chapter.reload.incidents_sequence_number}.from(100).to(101)
  end

  it "resets the sequence if the year has changed" do
    chapter.update_attributes incidents_sequence_year: '2010'
    expect {
      expect(sequence.next_sequence!).to eq('14-0001')
    }.to change{chapter.reload.incidents_sequence_year}.to(2014)
  end


end