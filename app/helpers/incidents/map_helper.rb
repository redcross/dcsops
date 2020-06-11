module Incidents::MapHelper
  def map_config scope
    bounds = scope.region.try(:incidents_geocode_bounds).try(:presence) || '0,0,0,0'
    bounds = bounds.split(',').map(&:to_f)
    {lat: scope.incidents_map_center_lat.try(:to_f), lng: scope.incidents_map_center_lng.try(:to_f), zoom: scope.incidents_map_zoom, geocode_bounds: bounds}
  end

  def google_maps_javascript(libraries=[])
    api_key = ENV['GOOGLE_MAPS_API_KEY']
    if api_key
      api_key = "&key=#{api_key}"
    else
      api_key = ""
    end
    javascript_include_tag "https://maps.googleapis.com/maps/api/js?#{api_key}&libraries=places"
  end
end