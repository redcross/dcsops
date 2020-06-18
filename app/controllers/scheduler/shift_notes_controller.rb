class Scheduler::ShiftNotesController < Scheduler::BaseController
  inherit_resources
  respond_to :html, :json
  defaults resource_class: Scheduler::ShiftAssignment
  actions :index, :update
  load_and_authorize_resource class: "Scheduler::ShiftAssignment"

  has_scope :date, default: ->controller{Date.current.to_s} do |controller, scope, val|
    d = Date.parse val
    scope.where{date == d}
  end

  protected

  def update_resource resource, attrs
    resource.send(:attributes=, *attrs)
    resource.save validate: false
  end

  def end_of_association_chain
    Scheduler::ShiftAssignment.joins{person}.where{person.region_id==my{current_region}}.readonly(false)
  end

  def collection
    @collection ||= apply_scopes(end_of_association_chain).joins{[shift, shift_time]}.order{[shift.ordinal, shift_time.start_offset, person_id]}.preload{[shift.shift_territory, person, shift, shift_time]}
  end

  def build_resource_params
    [params.fetch(:scheduler_shift_assignment).permit(:note)]
  end
end
    