class Scheduler::HomeController < Scheduler::BaseController

  def root
    authorize! :read, current_person
  end

  private
  helper_method :shifts_available_for_month
  def shifts_available_for_month(month, scope={:mine => current_user})
    groups = Scheduler::ShiftGroup.where(chapter_id: current_user.chapter_id)
    @shifts ||= groups.map{|group| group.shifts.includes{positions}}.flatten.select{|shift|
      if scope[:mine]
        shift.can_be_taken_by? scope[:mine]
      end
    }

    Scheduler::Shift.count_shifts_available_for_month(@shifts, month)
  end

  helper_method :upcoming_shifts
  def upcoming_shifts
    @upcoming_shifts ||= Scheduler::ShiftAssignment.where(person_id: current_person).references(:shift => :shift_group).starts_after(DateTime.now).includes(:shift => :shift_group).order('scheduler_shift_assignments.date asc, scheduler_shift_groups.start_offset asc').first(3)
  end

  def current_person
    @_current_person ||= (params[:person_id] ? Roster::Person.find( params[:person_id]) : current_user)
  end

  helper_method :available_swaps
  def available_swaps
    @available_swaps ||= Scheduler::ShiftAssignment.references(:shift => :shift_group).starts_after(DateTime.now).includes(:shift => :shift_group).order('scheduler_shift_assignments.date asc, scheduler_shift_groups.start_offset asc').where(available_for_swap: true).select{|shift| shift.shift.can_be_taken_by? current_person}
  end

  helper_method :days_of_week, :shift_times, :current_person
    def days_of_week
      %w(sunday monday tuesday wednesday thursday friday saturday)
    end

    def shift_times
      %w(day night)
    end
end
