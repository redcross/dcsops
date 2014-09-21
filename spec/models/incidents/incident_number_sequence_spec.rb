require 'spec_helper'

describe Incidents::NumberSequence do

  let(:sequence) { Incidents::NumberSequence.create current_number: 100, current_year: '2014', format: "%<fy_short>02d-%<number>04d" }

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
    sequence.update format: "%<fy>02d-%<number>03d"
    expect(sequence.next_sequence!).to eq('2014-101')
  end

  it "increments the stored sequence" do
    expect{
      expect(sequence.next_sequence!).to eq('14-0101')
    }.to change{sequence.reload.current_number}.from(100).to(101)
  end

  it "resets the sequence if the year has changed" do
    sequence.update current_year: '2010'
    expect {
      expect(sequence.next_sequence!).to eq('14-0001')
    }.to change{sequence.reload.current_year}.to(2014)
  end

  it "can be called multiple times" do
    expect(sequence.next_sequence!).to eq('14-0101')
    expect(sequence.next_sequence!).to eq('14-0102')
    expect(sequence.next_sequence!).to eq('14-0103')
  end

  describe "Multithreaded" do
    include ::TruncationStrategy

    it "is roughly threadsafe" do
      num_threads = 4

      sequence.update current_number: 0
      threads = num_threads.times.map do
        Thread.new do
          sequence.class.connection_pool.with_connection do
            200.times do
              sequence.next_sequence!
            end
          end
        end
      end

      threads.each(&:join)

      expect(sequence.reload.current_number).to eq(num_threads * 200)

    end
  end

end