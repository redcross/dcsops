module Scheduler::HomeHelper

  def calendar_month(month, *args)
    scheduler_calendar_path(month.year, month.strftime("%B").downcase, *args)
  end

end
