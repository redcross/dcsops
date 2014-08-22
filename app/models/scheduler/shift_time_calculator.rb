class Scheduler::ShiftTimeCalculator
  def initialize(time_zone)
    @time_zone = time_zone
  end

  attr_reader :time_zone

  def local_offset(date, offset)
    #date.in_time_zone.at_beginning_of_day.advance( seconds: offset).iso8601

    beginning_of_day = date.in_time_zone(time_zone).at_beginning_of_day
    offset_time = beginning_of_day.advance(offset)

    # advance counts every instant that elapses, not just calendar seconds.  so
    # when crossing DST you might end up one hour off in either direction even though
    # you just want "wall clock" time.  So if the offset of the two times is different, we
    # negate it.
    if beginning_of_day.utc_offset != offset_time.utc_offset
      offset_time = offset_time.advance seconds: (beginning_of_day.utc_offset - offset_time.utc_offset)
    end

    offset_time
  end
end