require 'spec_helper'

describe Scheduler::ShiftRecommendationScore, :type => :model do
  let(:incident) {FactoryGirl.create(:incident, chapter: shift.chapter)}
  let(:chapter) {FactoryGirl.create :chapter}
  let(:position) {FactoryGirl.create :position, chapter: chapter}
  let(:county) {FactoryGirl.create :county, chapter: chapter}
  let(:shift_group) {FactoryGirl.create :shift_group, chapter: chapter}
  let(:shift) {FactoryGirl.create :shift, shift_groups: [shift_group], positions: [position], county: county}
  let(:date) {shift.county.chapter.time_zone.today}
  let(:person) { FactoryGirl.create :person, chapter: chapter, counties: [shift.county], positions: shift.positions}

  describe "get_score" do
    it "returns a number" do
      score = Scheduler::ShiftRecommendationScore.get_score(shift, shift_group, date)
      expect(score).to be <= 5
      expect(score).to be >= 0
    end
  end

  describe "calls_with_positive_response" do
    context "matches chapter" do
      it "returns the number of calls including matching chapter" do
        FactoryGirl.create(:responder_assignment, incident: incident)
        score = Scheduler::ShiftRecommendationScore.calls_with_positive_response(shift, shift_group, date)
        expect(score).to eq 1
      end

      it "does not calls that don't match chapter" do
        incident_with_other_chapter = FactoryGirl.create(:incident, chapter: Roster::Chapter.new)
        FactoryGirl.create(:responder_assignment, incident: incident_with_other_chapter)
        score = Scheduler::ShiftRecommendationScore.calls_with_positive_response(shift, shift_group, date)
        expect(score).to eq 0
      end
    end

    context "positive response calls" do
      it "returns number of calls including positive responses" do
        FactoryGirl.create(:responder_assignment, incident: incident, role: Incidents::ResponderAssignment::ROLES.first)
        score = Scheduler::ShiftRecommendationScore.calls_with_positive_response(shift, shift_group, date)
        expect(score).to eq 1
      end

      it "doesn't include calls with negative responses" do
        FactoryGirl.create(:responder_assignment, incident: incident, role: Incidents::ResponderAssignment::RESPONSES.first)
        score = Scheduler::ShiftRecommendationScore.calls_with_positive_response(shift, shift_group, date)
        expect(score).to eq 0
      end
    end

    #waiting for nicolette's commit
    xcontext "matches date" do
      it "returns the number of calls including matching date and time of group" do
        incident = FactoryGirl.create(:incident, chapter: shift.chapter)
        FactoryGirl.create(:responder_assignment, incident: incident)
        score = Scheduler::ShiftRecommendationScore.calls_with_positive_response(shift, shift_group, date)
        expect(score).to eq 1
      end

      it "doesn't return calls that don't match date" do
        incident = FactoryGirl.create(:incident, chapter: shift.chapter)
        FactoryGirl.create(:responder_assignment, incident: incident)
        score = Scheduler::ShiftRecommendationScore.calls_with_positive_response(shift, shift_group, 1.day.ago)
        expect(score).to eq 0
      end

      it "doesn't return calls that don't match time offet of group" do
        shift_group = FactoryGirl.create :shift_group, chapter: chapter, start_offset: 0, end_offset: 2.hours
        incident = FactoryGirl.create(:incident, chapter: shift.chapter)
        assignment = FactoryGirl.create(:responder_assignment, incident: incident)
        assignment.update_attribute(:created_at, Time.current.beginning_of_day + 4.hours)
        score = Scheduler::ShiftRecommendationScore.calls_with_positive_response(shift, shift_group, date)
        expect(score).to eq 0
      end
    end

  end

end
