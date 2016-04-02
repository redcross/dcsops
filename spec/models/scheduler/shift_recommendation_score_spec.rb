require 'spec_helper'

describe Scheduler::ShiftRecommendationScore, :type => :model do
  describe "get_score" do

    let(:chapter) {FactoryGirl.create :chapter}
    let(:position) {FactoryGirl.create :position, chapter: chapter}
    let(:county) {FactoryGirl.create :county, chapter: chapter}
    let(:shift_group) {FactoryGirl.create :shift_group, chapter: chapter}
    let(:shift) {FactoryGirl.create :shift, shift_groups: [shift_group], positions: [position], county: county}
    let(:date) {shift.county.chapter.time_zone.today}
    let(:person) { FactoryGirl.create :person, chapter: chapter, counties: [shift.county], positions: shift.positions}

    it "returns a number" do
      score = Scheduler::ShiftRecommendationScore.get_score(shift, shift_group, date)
      expect(score).to be <= 5
      expect(score).to be >= 0
    end
  end

end
