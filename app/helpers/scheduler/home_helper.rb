module Scheduler::HomeHelper

  def calendar_month(month, *args)
    scheduler_calendar_path(month.year, month.strftime("%B").downcase, *args)
  end

  def assignments_for_shifts(groups, shifts)
    if groups.present? and shifts.present?
      Scheduler::ShiftAssignment.for_active_groups(groups).for_shifts(shifts)
    else
      Scheduler::ShiftAssignment.none
    end
  end

  def current_shifts_tree(shift_territories, groups=nil)
    shift_territories = shift_territories.to_a
    groups ||= Scheduler::ShiftTime.current_groups_for_region(current_person.region, current_region.time_zone.now, Scheduler::ShiftTime.includes(:shifts))
    groups_by_id = groups.group_by(&:id)
    groups_by_shift = groups.reduce({}){|hash, group| group.shift_ids.each{|id| hash[id] = group}; hash }

    # Get the list of shifts we're going to display: only for given shift_territories, and only active on the current day for that shift
    shifts = Scheduler::Shift.for_groups(groups).for_shift_territories(shift_territories).order(:ordinal)
                             .select{|shift| group = groups_by_shift[shift.id]; shift.active_on_day?(group.start_date, group)}
    shifts_by_shift_territory = shifts.group_by(&:shift_territory_id)

    # The assignments for those shifts
    assignments_by_shift = assignments_for_shifts(groups, shifts_by_shift_territory.values.flatten.compact).group_by(&:shift_id)

    # Return a hash structure of shift_territory => { shift => [assignments]}
    # There has got to be a better way of doing this...
    Hash[shift_territories.map{|c| shifts = shifts_by_shift_territory[c.id] || []; [c, Hash[shifts.map{|sh| [sh, assignments_by_shift[sh.id] || []]}]]}]
  end
end
