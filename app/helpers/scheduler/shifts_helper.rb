module Scheduler::ShiftsHelper
  def counties_for_shift_group
    Roster::County.where(region_id: resource.shift_group.region_id)
  end
end
