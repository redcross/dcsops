module Scheduler::PeopleHelper

  def flex_schedules
    ids = collection.to_a.map(&:id)
    @flex_schedules ||= Scheduler::FlexSchedule.where(id: ids).group_by(&:id)
  end

  def flex_schedule_for person_id
    flex_schedules[person_id].try :first
  end
end