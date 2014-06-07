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

  def current_shifts_tree(counties, groups=nil)
    counties = counties.to_a
    groups ||= Scheduler::ShiftGroup.current_groups_for_chapter(current_person.chapter, current_chapter.time_zone.now, Scheduler::ShiftGroup.includes{shifts})
    groups_by_id = groups.group_by(&:id)
    groups_by_shift = groups.reduce({}){|hash, group| group.shift_ids.each{|id| hash[id] = group}; hash }

    # Get the list of shifts we're going to display: only for given counties, and only active on the current day for that shift
    shifts = Scheduler::Shift.for_groups(groups).for_counties(counties).order(:ordinal)
                             .select{|shift| group = groups_by_shift[shift.id]; shift.active_on_day?(group.start_date, group)}
    shifts_by_county = shifts.group_by(&:county_id)

    # The assignments for those shifts
    assignments_by_shift = assignments_for_shifts(groups, shifts_by_county.values.flatten.compact).group_by(&:shift_id)

    # Return a hash structure of county => { shift => [assignments]}
    # There has got to be a better way of doing this...
    Hash[counties.map{|c| shifts = shifts_by_county[c.id] || []; [c, Hash[shifts.map{|sh| [sh, assignments_by_shift[sh.id] || []]}]]}]
  end
end
