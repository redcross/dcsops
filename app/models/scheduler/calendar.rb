class Scheduler::Calendar
  # Calendar is a service class that retrieves all of the objects (group, shift, 
  # assignment) needed to render a calendar for a given date range

  attr_reader :chapter, :start_date, :end_date, :person, :filter, :counties, :categories

  def initialize(chapter, start_date, end_date, person: nil, filter: :mine, counties: nil, categories: nil)
    @chapter = chapter
    @start_date = start_date
    @end_date = end_date
    @person = person
    @filter = filter
    @counties = counties
    @categories = categories

    load_shifts
  end

  def daily_groups
    @_daily_groups ||= filter_shifts(shifts_by_period 'daily')
  end

  def weekly_groups
    @_weekly_groups ||= filter_shifts(shifts_by_period 'weekly')
  end

  def monthly_groups
    @_monthly_groups ||= filter_shifts(shifts_by_period 'monthly')
  end

  def all_groups
    daily_groups.merge(weekly_groups).merge(monthly_groups)
  end

  def assignments_for_shift_on_day(shift, date)
    @all_shifts[shift.id][date] || []
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

  def date_range
    start_date.at_beginning_of_week.advance(weeks: -1)..end_date
  end

  def load_all_shifts
    shifts = all_groups.values.flatten
    @all_assignments = Scheduler::ShiftAssignment.includes_person_carriers
        .includes{[person.counties, shift.county, shift.positions, shift.shift_group]}
        .for_shifts(shifts).where{date.in(my{date_range})}
    
    @all_shifts = Hash.new{|h,k| h[k] = NestedHash.default_hash(Array) }
    @all_assignments.each do |assignment|
      @all_shifts[assignment.shift_id][assignment.date] << assignment
    end
  end

  def load_my_shifts
    @my_shifts = NestedHash.hash_hash_array
    if person
      group_ids = all_groups.keys
      pid = person.id

      Scheduler::ShiftAssignment.joins{shift}.includes{shift}
          .where{(shift.shift_group_id.in(group_ids)) & (person_id == pid) & date.in(my{date_range})}
          .each do |assignment|
        @my_shifts[assignment.shift.shift_group_id][assignment.date] << assignment
      end
    end
  end

  def shifts_by_period(period)
    @_unfiltered_shifts ||= Scheduler::ShiftGroup.includes{[shifts.positions, shifts.county, shifts.shift_group.chapter]}.where(chapter_id: chapter).order(:start_offset).to_a

    @_unfiltered_shifts.select{|sh| sh.period == period}
  end

  def filter_shifts(groups)
    groups.inject({}){|hash, group|
      shifts = case filter
      when :all then group.shifts
      when :county then group.shifts.select{|s| 
        (counties.nil? || counties.include?(s.county_id)) && 
        (categories.nil? || categories.include?(s.shift_category_id))
      }
      when :mine then group.shifts.select{|s| person and s.can_be_taken_by? person}
      end
      hash[group] = shifts if shifts.present?
      hash
    }
  end

  def load_by_day_group
    @by_day_group ||= Hash.new{|h,k| h[k] = Hash.new{|h,k| h[k] = Hash.new }}
    @all_assignments.each { |shift| @by_day_group[shift.person][shift.date][shift.shift.shift_group] = shift; }
  end

end