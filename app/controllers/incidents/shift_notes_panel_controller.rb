class Incidents::ShiftNotesPanelController < Incidents::BaseController
  inherit_resources
  defaults resource_class: Scheduler::ShiftAssignment
  actions :index

  def collection
    @collection ||= Scheduler::ShiftAssignment.todays_shifts_with_notes current_region
  end
end
