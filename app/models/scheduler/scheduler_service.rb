class Scheduler::SchedulerService
  attr_reader :chapter
  def initialize(chapter)
    raise InvalidArgument, 'Chapter cannot be nil' unless chapter
    @chapter = chapter
  end

  def scheduled_responders(time: chapter.time_zone.now, limit: nil, area: nil, exclude: [])
    groups = Scheduler::ShiftGroup.current_groups_for_chapter(chapter, time)
    assignments = Scheduler::ShiftAssignment.joins{[shift]}.includes{[shift, person]}.for_active_groups(groups)
                  .where{person_id.not_in(exclude)}.limit(limit)
    if area
      assignments = assignments.where{shift.county_id == area}
    end

    assignments.to_a
  end

  def flex_responders(time: chapter.time_zone.now, limit: nil, area: nil, exclude: [])
    dow = time.strftime("%A").downcase
    hour = time.hour
    period = (hour >= 7 && hour < 19) ? 'day' : 'night'

    schedules = Scheduler::FlexSchedule.available_at(dow, period).joins{person}.where{person.chapter_id == my{chapter}}.includes{person}
    if area
      schedules = schedules.for_county(area)
    end

    people = schedules.where{id.not_in(exclude)}
    people.to_a
  end

  def dispatch_assignments(time: chapter.time_zone.now, area: nil)
    groups = Scheduler::ShiftGroup.current_groups_for_chapter(chapter, time)
    assignments = Scheduler::ShiftAssignment.joins{shift}.for_active_groups(groups).where{(shift.dispatch_role != nil)}
    if area
      assignments = assignments.where{(shift.county_id == area)}
    end
    assignments.to_a
  end
end