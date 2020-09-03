class Scheduler::SchedulerService
  attr_reader :region
  def initialize(region)
    raise InvalidArgument, 'Region cannot be nil' unless region
    @region = region
  end

  def scheduled_responders(time: region.time_zone.now, limit: nil, shift_territories: nil, exclude: [], shifts: nil, dispatch_console: false)
    groups = Scheduler::ShiftTime.current_groups_for_region(region, time)
    assignments = Scheduler::ShiftAssignment.joins(:shift).preload(:shift, :person).for_active_groups(groups)
                  .where.not(person_id: exclude).limit(limit)
    if shift_territories.present?
      assignments = assignments.where(scheduler_shifts: { shift_territory_id: shift_territories })
    end
    if shifts
      assignments = assignments.where(shift_id: shifts)
    end
    if dispatch_console
      assignments = assignments.where(scheduler_shifts: { show_in_dispatch_console: true })
    end

    assignments
  end

  def flex_responders(time: region.time_zone.now, limit: nil, shift_territories: nil, exclude: [], origin: nil)
    dow = time.strftime("%A").downcase
    offset = time.seconds_since_midnight
    period = (offset >= region.scheduler_flex_day_start && offset < region.scheduler_flex_night_start) ? 'day' : 'night'

    schedules = Scheduler::FlexSchedule.available_at(dow, period).joins(:person).eager_load(:person).where(roster_people: { region_id: region })
    if shift_territories.present?
      schedules = schedules.for_shift_territory(shift_territories)
    end
    if origin
      schedules = schedules.by_distance_from origin
    end

    people = schedules.where.not(id: exclude).preload(person: [:positions, :cell_phone_carrier, :work_phone_carrier, :home_phone_carrier, :alternate_phone_carrier, :sms_phone_carrier]).limit(limit).to_a.uniq{|s| s.id }
  end

  def dispatch_assignments(time: region.time_zone.now, response_territory: )
    config = response_territory.dispatch_config
    if config
      groups = Scheduler::ShiftTime.current_groups_for_region(region, time)
      shifts = config.shift_list
      assignments = Scheduler::ShiftAssignment.for_active_groups(groups).for_shifts(shifts).includes(:shift).sort_by{|sa| shifts.index(sa.shift) }
      backup = config.backup_list
      {present: true, assignments: assignments, backup: backup}
    else
      {present: false, assignments: [], backup: []}
    end
  end
end