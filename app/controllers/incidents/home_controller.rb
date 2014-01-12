class Incidents::HomeController < Incidents::BaseController
  helper Incidents::MapHelper, Incidents::HomeControllerHelper

  def root
  end

  def operations

  end

  def map
    params[:q] ||= {date_gteq: '2012-07-01'}
    @search = Incidents::Incident.search(params[:q])
    @incidents = @search.result.for_chapter(current_chapter).valid.where{(lat != nil) & (lng != nil)}
  end

  private

  helper_method :recent_incidents
  expose(:recent_incidents) {
    Incidents::Incident.for_chapter(current_chapter).valid.includes{[dat_incident, event_logs]}.order{incident_number.desc}.order{date.desc}.limit(15)
  }
end
