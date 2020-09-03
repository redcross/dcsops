class Incidents::ReportSubscriptionsController < Incidents::BaseController
  inherit_resources
  respond_to :html, :json
  belongs_to :scope, parent_class: Incidents::Scope, finder: :find_by_url_slug!
  load_and_authorize_resource
  helper EditableHelper

  rescue_from ActiveRecord::RecordNotFound do |ex|
    redirect_to action: :new
  end

  actions :all, except: [:index, :edit]

  def create
    create! { resource_path(build_resource.person_id) }
  end

  def destroy
    destroy! { new_resource_path }
  end

  private

  def build_resource
    @notification_subscription ||= Incidents::ReportSubscription.new new_resource_params
  end

  def resource
    @notification_subscription ||= Incidents::ReportSubscription.find_by! new_resource_params
  end

  def new_resource_params
    {person_id: current_user, report_type: params[:report_type], scope: parent}
  end

  def resource_params
    request.put? ? [params.require(:incidents_report_subscription).permit(:frequency)] : []
  end

  expose(:show_select_frequency) {
    resource.assignable_frequencies.length > 1
  }
end