class Incidents::NotificationSubscriptionsController < Incidents::BaseController
  inherit_resources
  respond_to :html, :json
  load_and_authorize_resource
  helper EditableHelper

  rescue_from ActiveRecord::RecordNotFound do |ex|
    redirect_to action: :new
  end

  def create
    create! { incidents_notification_subscription_report_path(build_resource.person_id) }
  end

  def destroy
    destroy! { incidents_notification_subscription_report_path(resource.person_id) }
  end

  private

  def build_resource
    @notification_subscription ||= Incidents::NotificationSubscription.new person_id: params[:id], notification_type: params[:notification_type]
  end

  def resource
    @notification_subscription ||= Incidents::NotificationSubscription.find_by! person_id: params[:id], notification_type: params[:notification_type]
  end

  def resource_params
    request.get? ? [] : [params.require(:incidents_notification_subscription).permit(:frequency)]
  end

  expose(:show_select_frequency) {
    resource.assignable_frequencies.length > 1
  }
end