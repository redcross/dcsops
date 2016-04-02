class Scheduler::ShiftRecommendationScore

  def self.get_score(shift, shift_group, date)
    rand(5).to_i
  end

  def self.calls_with_positive_response(shift, shift_group, date)
    Incidents::ResponderAssignment.
      for_chapter(shift.chapter).
      was_available.
      #need to match day of week, time slot, and prev 12 months of shift group and date here
      count
  end

end
