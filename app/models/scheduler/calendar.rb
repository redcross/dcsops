class Scheduler::Calendar
  # Calendar is a service class that retrieves all of the objects (group, shift, 
  # assignment) needed to render a calendar for a given date range
  include ::NewRelic::Agent::MethodTracer

  attr_reader :region, :start_date, :end_date, :person, :filter, :shift_territories, :categories

  def initialize(region, start_date, end_date, person: nil, filter: :mine, shift_territories: nil, categories: nil)
    @region = region
    @start_date = start_date
    @end_date = end_date
    @person = person
    @filter = filter
    @shift_territories = shift_territories
    @categories = categories

    load_shifts
  end

  def daily_groups
    @_daily_groups ||= filter_shifts(groups_by_period 'daily')
  end

  def weekly_groups
    @_weekly_groups ||= filter_shifts(groups_by_period 'weekly')
  end

  def monthly_groups
    @_monthly_groups ||= filter_shifts(groups_by_period 'monthly')
  end

  def all_groups
    @all_groups ||= daily_groups.merge(weekly_groups).merge(monthly_groups)
  end

  def assignments_for_group_on_day(group, date)
    (@all_shifts[group.id][date] || {}).values.flatten
  end

  def assignments_for_shift_on_day_in_group(shift, date, group)
    @all_shifts[group.id][date][shift.id] || []
  end

  def my_shifts_for_group_on_day(group_id, date)
    @my_shifts[group_id][date]
  end

  def assignment_for_person_on_day_in_group(person, day, group)
    load_by_day_group unless @by_day_group
    @by_day_group[person][day][group]
  end

  def people_with_shifts
    load_by_day_group unless @by_day_group
    @by_day_group.keys
  end

  private


  def load_shifts
    load_all_shifts
    load_my_shifts
  end
  add_method_tracer :load_shifts

  def date_range
    start_date.at_beginning_of_week.advance(weeks: -0)..end_date
  end

  def load_all_shifts
    shifts = all_groups.values.flatten
    @all_assignments = Scheduler::ShiftAssignment.references(:shift)#.includes_person_carriers
        .includes(:person, :shift_time, shift: [:shift_territories, :positions]) # person.counties,
        .for_shifts(shifts).where(date: date_range)
    
    @all_shifts = Core::NestedHash.hash_hash_hash_array
    @all_assignments.each do |assignment|
      @all_shifts[assignment.shift_time_id][assignment.date][assignment.shift_id] << assignment
    end
  end

  def load_my_shifts
    @my_shifts = Core::NestedHash.hash_hash_array
    if person
      group_ids = all_groups.keys
      pid = person.id

      Scheduler::ShiftAssignment.references(:shift).includes(:shift_time, shift: :shift_times)
          .where(shift_time_id: time_ids, person_id: pid, date: date_range)
          .each do |assignment|
        @my_shifts[assignment.shift_time_id][assignment.date] << assignment
      end
    end
  end

  def groups_by_period(period)
    # The references(:shifts) forces all of the preloads to be generated as one massive join.  Maybe
    # not so good for the database, but rails seems to be pathalogically slow on this eager load.
    @_unfiltered_groups ||= Scheduler::ShiftTime.references(:shifts).includes(shifts: [:positions, :shift_territory, :shift_times]).where(region_id: region).order(:start_offset).to_a

    @_unfiltered_groups.select{|sh| sh.period == period}
  end

  def filter_shifts(groups)
    groups.inject({}){|hash, group|
      shifts = case filter
      when :all then group.shifts
      when :shift_territory then group.shifts.select{|s| 
        (shift_territories.nil? || shift_territories.include?(s.shift_territory_id)) && 
        (categories.nil? || categories.include?(s.shift_category_id))
      }
      when :mine then group.shifts.select{|s| person and s.can_be_taken_by? person}
      end
      hash[group] = shifts if shifts.present?
      hash
    }
  end

  def load_by_day_group
    @by_day_group ||= Core::NestedHash.hash_hash_hash
    @all_assignments.each { |ass| @by_day_group[ass.person][ass.date][ass.shift_time] = ass; }
  end

end