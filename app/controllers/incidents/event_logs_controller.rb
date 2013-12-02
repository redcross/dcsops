class Incidents::EventLogsController < Incidents::BaseController
  inherit_resources
  load_and_authorize_resource
  belongs_to :incident, finder: :find_by_incident_number!, parent_class: Incidents::Incident

  actions :all, except: [:show, :index]

  respond_to :html, :js

  layout ->controller{ controller.xhr? ? false : nil }

  def update
    action = params[:action] == 'create' ? :create! : :update!
    self.send(action) do |success, failure|
      success.js { render action: 'update' }
      failure.js { pp resource.errors; render action: 'edit', layout: nil}
    end
  end
  alias_method :create, :update

  def build_resource
    super.tap{|log| log.event_time ||= Time.current }
  end

  def resource_params
    request.get? ? [] : [params.require(:incidents_event_log).permit(:event, :event_time, :message).merge(person_id: current_user.id)]
  end

  def xhr?
    request.xhr?.present?
  end
end