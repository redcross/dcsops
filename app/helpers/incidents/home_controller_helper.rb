module Incidents::HomeControllerHelper
  include Exposure
  expose(:num_incidents_to_link) do
    Incidents::CasIncident.to_link_for_region(scope.region).count
  end

  def stats(date_range)
    stats = scope.incidents.where{date.in(date_range)}.valid
    stats = stats.with_status 'closed' if current_region.incidents_report_editable
    stats.incident_stats
  end

  expose :incident_stats_boxes do
    today = current_region.time_zone.today
    month_begin = today.at_beginning_of_month
    last_month = month_begin.last_month

    fy_begin = FiscalYear.current.start_date
    five_fy_begin = fy_begin.advance years: -4

    {"#{month_begin.strftime("%B")} To Date" => stats(month_begin..today), 
    "#{last_month.strftime("%B")}" => stats(last_month..last_month.end_of_month), 
    "FYTD" => stats(fy_begin..today)}
  end

  def time_on_at time
    if time.to_date == Date.current
      time.to_s :at_time
    else
      time.to_s :on_date_at_time
    end
  end

  def map_json_for(incidents)
    incidents.joins{region}.pluck(:incident_number, :lat, :lng, :num_adults, :num_children, :status, "roster_regions.url_slug").map do |inc|
      {id: inc[0], lat: inc[1], lng: inc[2], clients: [inc[3], inc[4]].compact.sum, status: inc[5], url: incidents_region_incident_path(inc[6], inc[0])}
    end
  end
end
