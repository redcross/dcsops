class Incidents::EventLogsController < Incidents::EditPanelController
  self.panel_name = 'timeline'

  protected

  def build_resource
    super.tap{|log| log.event_time ||= Time.current }
  end

  def resource_params
    request.get? ? [] : [params.require(:incidents_event_log).permit(:event, :event_time, :message).merge(person_id: current_user.id)]
  end
end