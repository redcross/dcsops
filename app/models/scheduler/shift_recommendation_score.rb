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

end
