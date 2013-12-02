module Incidents::MapHelper
  def map_config
    chapter = current_chapter
    bounds = chapter.incidents_geocode_bounds || '0,0,0,0'
    bounds = bounds.split(',').map(&:to_f)
    {lat: current_chapter.incidents_map_center_lat.try(:to_f), lng: current_chapter.incidents_map_center_lng.try(:to_f), zoom: current_chapter.incidents_map_zoom, geocode_bounds: bounds}
  end

  def google_maps_javascript
    api_key = ENV['GOOGLE_MAPS_API_KEY']
    if api_key
      api_key = "&client=#{api_key}"
    else
      api_key = ""
    end
    javascript_include_tag "https://maps.googleapis.com/maps/api/js?v=3.exp&sensor=false#{api_key}"
  end
end