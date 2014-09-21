class Scheduler::SchedulerService
  attr_reader :chapter
  def initialize(chapter)
    raise InvalidArgument, 'Chapter cannot be nil' unless chapter
    @chapter = chapter
  end

  def scheduled_responders(time: chapter.time_zone.now, limit: nil, areas: nil, exclude: [], shifts: nil)
    groups = Scheduler::ShiftGroup.current_groups_for_chapter(chapter, time)
    assignments = Scheduler::ShiftAssignment.joins{[shift]}.preload{[shift, person]}.for_active_groups(groups)
                  .where{person_id.not_in(exclude)}.limit(limit)
    if areas.present?
      assignments = assignments.where{shift.county_id.in areas}
    end
    if shifts
      assignments = assignments.where{shift_id.in(shifts)}
    end

    assignments
  end

  def flex_responders(time: chapter.time_zone.now, limit: nil, areas: nil, exclude: [], origin: nil)
    dow = time.strftime("%A").downcase
    offset = time.seconds_since_midnight
    period = (offset >= chapter.scheduler_flex_day_start && offset < chapter.scheduler_flex_night_start) ? 'day' : 'night'

    schedules = Scheduler::FlexSchedule.available_at(dow, period).joins{person}.where{person.chapter_id == my{chapter}}.preload{person}
    if areas.present?
      schedules = schedules.for_county(areas)
    end
    if origin
      schedules = schedules.by_distance_from origin
    end

    people = schedules.where{id.not_in(exclude)}.preload{[person.positions, person.cell_phone_carrier, person.work_phone_carrier, person.home_phone_carrier, person.alternate_phone_carrier, person.sms_phone_carrier]}.limit(limit)
  end

  def dispatch_assignments(time: chapter.time_zone.now, territory: )
    config = territory.dispatch_config
    if config
      groups = Scheduler::ShiftGroup.current_groups_for_chapter(chapter, time)
      shifts = config.shift_list
      assignments = Scheduler::ShiftAssignment.for_active_groups(groups).for_shifts(shifts).includes{shift}.sort_by{|sa| shifts.index(sa.shift) }
      backup = config.backup_list
      {present: true, assignments: assignments, backup: backup}
    else
      {present: false, assignments: [], backup: []}
    end
  end
end