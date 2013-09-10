class Scheduler::HomeController < Scheduler::BaseController

  def root
    authorize! :read, current_person if current_person != current_user
  end

  def on_call

  end

  private
  helper_method :shifts_available_for_month
  def shifts_available_for_month(month, scope={:mine => current_person})
    @shifts = Scheduler::Shift.includes{[positions, shift_group, county]}.where{shift_group.chapter_id == my{current_person.chapter_id}}.select{|shift|
      if scope[:mine]
        shift.can_be_taken_by? scope[:mine]
      end
    }

    Scheduler::Shift.count_shifts_available_for_month(@shifts, month)
  end

  helper_method :upcoming_shifts
  def current_time
    current_person.chapter.time_zone.now
  end

  def upcoming_shifts
    @upcoming_shifts ||= Scheduler::ShiftAssignment.where(person_id: current_person).references(:shift => :shift_group).starts_after(current_time).includes(:shift => :shift_group).order('scheduler_shift_assignments.date asc, scheduler_shift_groups.start_offset asc').first(3)
  end

  def current_person
    @_current_person ||= (params[:person_id] ? Roster::Person.find( params[:person_id]) : current_user)
  end

  helper_method :available_swaps
  def available_swaps
    @available_swaps ||= Scheduler::ShiftAssignment.references(:shift => :shift_group)
      .starts_after(current_time).includes(:shift => [:shift_group, :county])
      .order('scheduler_shift_assignments.date asc, scheduler_shift_groups.start_offset asc')
      .where(available_for_swap: true).select{|shift| shift.shift.can_be_taken_by? current_person}
  end

  helper_method :responses
  def responses
    @_responses ||= Incidents::ResponderAssignment.where(person_id: current_person).joins{incident}.order('incidents_incidents.date desc').first(5)
  end

  helper_method :days_of_week, :shift_times, :current_person
    def days_of_week
      %w(sunday monday tuesday wednesday thursday friday saturday)
    end

    def shift_times
      %w(day night)
    end
end
