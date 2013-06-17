class Incidents::EventLogsController < Incidents::BaseController
  inherit_resources
  load_and_authorize_resource
  belongs_to :incident, finder: :find_by_incident_number!, parent_class: Incidents::Incident

  actions :new, :create

  respond_to :js

  def create
    create! { |success, failure|
      success.js { render action: 'show'}
      failure.js { render action: 'create'}
    }
  end

  def build_resource
    return @event_log if defined? @event_log

    super
    @event_log.person = current_user
    @event_log
  end

  def resource_params
    request.get? ? [] : [params.require(:incidents_event_log).permit(:event, :event_time, :message)]
  end
end