class Incidents::HomeController < Incidents::BaseController
  helper Incidents::MapHelper, Incidents::HomeControllerHelper
  responders :partial
  respond_to :html
  load_and_authorize_resource :scope, find_by: :url_slug, id_param: :region_id, class: 'Incidents::Scope', except: :redirect_to_region

  def root
    respond_with []
  end

  def redirect_to_region
    glob = params[:glob] || ""
    new_path = incidents_region_root_path(current_region) + "/#{glob}"
    match = Rails.application.routes.recognize_path(new_path)
    if match && match[:action] != "redirect_to_region"
      redirect_to new_path, status: :moved_permanently
    else
      raise ActiveRecord::RecordNotFound
    end
  end

  def valid_partial? name
    name == "recent_table"
  end

  private

  helper_method :recent_incidents
  expose(:recent_incidents) {
    scope.incidents.valid.includes(:dat_incident, :event_logs).order(:date, :id).reverse_order.limit(15).where(date: 14.days.ago..DateTime::Infinity.new)
  }

  def incident_path(inc)
    incidents_region_incident_path(inc.region, inc)
  end
  helper_method :incident_path

  attr_reader :scope
  def editable?
    scope.editable? && can?(:read, scope.region)
  end
  helper_method :scope, :editable?

end
