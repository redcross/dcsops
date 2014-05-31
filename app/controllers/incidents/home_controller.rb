class Incidents::HomeController < Incidents::BaseController
  helper Incidents::MapHelper, Incidents::HomeControllerHelper
  responders :partial
  respond_to :html
  load_and_authorize_resource :chapter, find_by: :url_slug, class: 'Roster::Chapter', except: :redirect_to_chapter

  def root
    respond_with []
  end

  def redirect_to_chapter
    glob = params[:glob] || ""
    new_path = incidents_chapter_root_path(current_chapter) + "/#{glob}"
    match = Rails.application.routes.recognize_path(new_path)
    if match && match[:action] != "redirect_to_chapter"
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
    Incidents::Incident.for_chapter(@chapter).valid.includes{[dat_incident, event_logs]}.order(:date, :incident_number).reverse_order.limit(15)
  }

  def incident_path(inc)
    incidents_chapter_incident_path(@chapter, inc)
  end
  helper_method :incident_path

end
