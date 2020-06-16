class Scheduler::ShiftNotesController < Scheduler::BaseController
  inherit_resources
  respond_to :html, :json
  defaults resource_class: Scheduler::ShiftAssignment
  actions :index, :update
  load_and_authorize_resource class: "Scheduler::ShiftAssignment"

  has_scope :date, only: :index, default: ->controller{Date.current.to_s} do |controller, scope, val|
    d = Date.parse val
    scope.where(date: d)
  end

  protected

  def update_resource resource, attrs
    resource.send(:attributes=, *attrs)
    resource.save validate: false
  end

  def collection
    @collection ||= apply_scopes(Scheduler::ShiftAssignment.ordered_shifts current_region)
  end

  def build_resource_params
    [params.fetch(:scheduler_shift_assignment).permit(:note)]
  end
end
    