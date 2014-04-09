module Incidents::ReportMailerHelper
  include Exposure

  def period_name
    size = @date_range.last - @date_range.first + 1
    case size
    when 7 then 'This Week'
    else 'This Report'
    end
  end

  def total_assistance_amount
    @incidents.map(&:total_assistance_amount).sum
  end

  # Methods for the incidents map
  def static_maps_url(retina=false, width=map_width, height=map_height)
    size = "#{width}x#{height}"
    scale = retina ? "2" : "1"
    "http://maps.googleapis.com/maps/api/staticmap?visual_refresh=true&sensor=false&size=#{size}&markers=#{URI::encode incidents_marker_param}&path=#{URI::encode path_param}&scale=#{scale}&key=AIzaSyBabBKA3eRH_Pj1UdHEvzISS0crsOScsf4"
  end

  def image_content
    uri = URI(static_maps_url)
    resp = Net::HTTP.get_response uri
    { content_type: resp['Content-Type'], content: resp.body }
  end

  def incidents_marker_param
    "|" + incidents.map{|i| [i.lat.to_s, i.lng.to_s].join(",")}.join("|")
  end

  def path_param
    "color:0x00000000|#{chapter.incidents_map_framing_points}"
  end
end