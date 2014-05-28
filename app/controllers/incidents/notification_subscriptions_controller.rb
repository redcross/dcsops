class Incidents::NotificationSubscriptionsController < Incidents::BaseController
  inherit_resources
  respond_to :html, :json
  belongs_to :chapter, parent_class: Roster::Chapter, finder: :find_by_url_slug!
  defaults route_collection_name: :report_subscriptions, route_instance_name: :report_subscription
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
    destroy! { resource_path(resource.person_id) }
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