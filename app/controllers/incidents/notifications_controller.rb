class Incidents::NotificationsController < Incidents::EditPanelController
  belongs_to_incident
  self.panel_name = ['details', 'timeline']
  defaults resource_class: Incidents::Notifications::Message, singleton: true
  custom_actions resource: :recipients

  def recipients
    event = Incidents::Notifications::Event.find_by!(id: params[:event_id], region_id: parent.region)
    notification = Incidents::Notifications::Notification.new parent, event
    @roles = notification.roles_for_event event
    render layout: nil
  end

  protected

  def resource
    @message ||= resource_class.new
  end

  def build_resource
    @message ||= resource_class.new *resource_params
  end

  def create_resource resource
    if resource.valid?
      event = resource.event
      Incidents::Notifications::Notification.create parent, event, message: resource.message
      parent.update_attributes notification_level_id: resource.event_id, notification_level_message: resource.message
      parent.event_logs.create person: current_user, event: 'note', message: "Notification sent to group #{event.name}: #{resource.message}", event_time: parent.region.time_zone.now
    else
      false
    end
  end

  def resource_params
    request.get? ? [{event_id: parent.notification_level_id}] : [params.require(:incidents_notifications_message).permit(:event_id, :message).merge({region_id: parent.region_id})]
  end

  # Need this to change the resource class name after the first load_and_authorize_resource call
  class NotificationsResource < CanCan::InheritedResources
    def resource_class; Incidents::NotificationsController.resource_class; end
  end
  def self.cancan_resource_class
    NotificationsResource
  end
end