class Incidents::HomeController < Incidents::BaseController
  helper Incidents::MapHelper, Incidents::HomeControllerHelper

  def root
  end

  def operations

  end

  private

  helper_method :recent_incidents
  expose(:recent_incidents) {
    Incidents::Incident.for_chapter(current_chapter).valid.includes{[dat_incident, event_logs]}.order(:date, :incident_number).reverse_order.limit(15)
  }
end
