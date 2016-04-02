class Scheduler::ShiftRecommendationScore

  def self.get_score(shift, shift_group, date)
    rand(5).to_i
  end

  def expected_number_of_incidents(unique_shift)
 	matching_incidents = Incidents::Incident
            .where(:chapter => unique_shift[:chapter])
            .where(:created_at => 12.months.ago..Time.now)
            .where("EXTRACT(DOW from date) = :day", {day: unique_shift[:day]})
            .where("EXTRACT(HOUR from created_at) BETWEEN :start AND :end", {start: unique_shift[:start_time], end: unique_shift[:end_time]}).count

        return matching_incidents/52
  end

  def unique_shift(shift, shift_group, day)
	generate_unique_shift = { day: day,
				  start_time: shift_group.start_offset/(60*60),
				  end_time: shift_group.end_offset/(60*60),
				  chapter: shift.chapter }
       return generate_unique_shift
  end

  def self.shift_response_rate(shift, shift_group, date)
    total_calls = total_calls(shift,shift_group,date)
    return 0 if total_calls.zero?
    calls_with_positive_response(shift,shift_group,date)/total_calls
  end

  private

  def self.calls_with_positive_response(shift, shift_group, date)
    Incidents::ResponderAssignment.
      for_chapter(shift.chapter).
      was_available.
      #need to match day/time
      count.to_f
  end

  def self.total_calls(shift, shift_group, date)
    Incidents::ResponderAssignment.
      for_chapter(shift.chapter).
      #need to match day/time
      count.to_f
  end

end
