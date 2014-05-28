class Incidents::HomeController < Incidents::BaseController
  helper Incidents::MapHelper, Incidents::HomeControllerHelper
  responders :partial
  respond_to :html

  def root
    respond_with []
  end

  def valid_partial? name
    name == "recent_table"
  end

  private

  helper_method :recent_incidents
  expose(:recent_incidents) {
    Incidents::Incident.for_chapter(current_chapter).valid.includes{[dat_incident, event_logs]}.order(:date, :incident_number).reverse_order.limit(15)
  }

end
