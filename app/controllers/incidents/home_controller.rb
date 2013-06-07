class Incidents::HomeController < ApplicationController

  def root
  end

  def map
    @search = Incidents::Incident.search(params[:q])
    @incidents = @search.result
  end

  private

  helper_method :recent_incidents, :map_json_for
  def recent_incidents
    @_recents ||= Incidents::Incident.order(:date).reverse_order.limit(7)
  end

  def map_json_for(incidents)
    incidents.map do |inc|
      {id: inc.incident_number, lat: inc.lat, lng: inc.lng, clients: inc.num_adults + inc.num_children}
    end
  end
end
