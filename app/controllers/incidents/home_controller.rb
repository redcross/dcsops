class Incidents::HomeController < Incidents::BaseController

  def root
  end

  def map
    @search = Incidents::Incident.search(params[:q])
    @incidents = @search.result.where{(lat != nil) & (lng != nil) & (lat.in 37.165368468295085..38.251787162859415) & (lng.in(-123.84274052031253..-121.45321415312503))}
  end

  private

  helper_method :recent_incidents, :map_json_for
  def recent_incidents
    @_recents ||= Incidents::Incident.includes{dat_incident}.order(:date).reverse_order.limit(7)
  end

  def map_json_for(incidents)
    incidents.map do |inc|
      {id: inc.incident_number, lat: inc.lat, lng: inc.lng, clients: inc.num_adults + inc.num_children}
    end
  end
end
