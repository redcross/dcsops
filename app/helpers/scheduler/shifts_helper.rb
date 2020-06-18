module Scheduler::ShiftsHelper
  def shift_territories_for_shift_time
    Roster::ShiftTerritory.where(region_id: resource.shift_time.region_id)
  end
end
