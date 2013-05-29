module Scheduler::CalendarHelper
  def assignments_for_shift_on_day(shift, date)
    Scheduler::ShiftAssignment.where(shift_id: shift, date: date).includes(:person)
  end
  
end
