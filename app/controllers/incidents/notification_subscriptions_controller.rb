class Incidents::NotificationSubscriptionsController < Incidents::BaseController
  inherit_resources
  load_and_authorize_resource

  rescue_from ActiveRecord::RecordNotFound do |ex|
    redirect_to action: :new
  end

  def create
    create! { incidents_notification_subscription_weekly_path(build_resource.person_id) }
  end

  def destroy
    destroy! { new_incidents_notification_subscription_weekly_path }
  end

  private

  def build_resource
    @notification_subscription ||= Incidents::NotificationSubscription.new person_id: params[:id], notification_type: params[:notification_type]
  end

  def resource
    @notification_subscription ||= Incidents::NotificationSubscription.find_by! person_id: params[:id], notification_type: params[:notification_type]
  end

  helper_method :formatted_narrative
  def formatted_narrative
    (resource.narrative || 'No Narrative Provided').gsub(/^(\[[^\]]+\])/, "\n\n#{'\1'}\n")
  end
end