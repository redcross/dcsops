module Scheduler::ShiftsHelper
  def counties_for_shift_group
    Roster::County.where(chapter_id: resource.shift_group.chapter_id)
  end
end
