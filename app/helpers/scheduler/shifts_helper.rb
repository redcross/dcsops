module Scheduler::ShiftsHelper
  def counties_for_shift_time
    Roster::County.where(region_id: resource.shift_time.region_id)
  end
end
