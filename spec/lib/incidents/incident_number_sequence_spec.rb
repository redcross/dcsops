require 'spec_helper'

describe Incidents::IncidentNumberSequence do

  let!(:chapter) { FactoryGirl.create :chapter, incidents_sequence_number: 100, incidents_sequence_year: FiscalYear.current.year, incidents_sequence_format: "%<fy_short>02d-%<number>04d" }
  let!(:sequence) { Incidents::IncidentNumberSequence.new chapter }

  it "generates a sequence number" do
    sequence.next_sequence!.should == '14-0101'
  end

  it "generates a sequence number according to the format" do
    chapter.update_attributes incidents_sequence_format: "%<fy>02d-%<number>03d"
    sequence.next_sequence!.should == '2014-101'
  end

  it "increments the stored sequence" do
    expect{
      sequence.next_sequence!.should == '14-0101'
    }.to change{chapter.reload.incidents_sequence_number}.from(100).to(101)
  end

  it "resets the sequence if the year has changed" do
    chapter.update_attributes incidents_sequence_year: '2010'
    expect {
      sequence.next_sequence!.should == '14-0001'
    }.to change{chapter.reload.incidents_sequence_year}.to(2014)
  end


end