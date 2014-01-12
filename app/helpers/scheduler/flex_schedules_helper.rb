module Scheduler::FlexSchedulesHelper
  def offset_to_time_string(offset)
    beginning_of_day = Time.zone.now.at_beginning_of_day
    offset_time = beginning_of_day.advance(seconds: offset)
    offset_time.advance seconds: (beginning_of_day.utc_offset - offset_time.utc_offset)
    offset_time.to_s :time
  end

  def flex_time_range(day_or_night, chapter = nil, joiner=" to ")
    chapter ||= resource.person.chapter
    times = [offset_to_time_string(chapter.scheduler_flex_day_start),
             offset_to_time_string(chapter.scheduler_flex_night_start)]
    times.reverse! if day_or_night == 'night'
    times.join joiner
  end

  def days_of_week
    Scheduler::FlexSchedule.days
  end

  def shift_times
    Scheduler::FlexSchedule.shifts
  end
end
