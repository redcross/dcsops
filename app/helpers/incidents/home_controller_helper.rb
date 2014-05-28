module Incidents::HomeControllerHelper
  include Exposure
  expose(:num_incidents_to_link) do
    Incidents::CasIncident.to_link_for_chapter(@chapter).count
  end

  def stats(date_range)
    scope = Incidents::Incident.for_chapter(@chapter).where{date.in(date_range)}.valid
    scope = scope.with_status 'closed' if @chapter.incidents_report_editable
    scope.incident_stats
  end

  expose :incident_stats_boxes do
    today = @chapter.time_zone.today
    month_begin = today.at_beginning_of_month
    last_month = month_begin.last_month

    fy_begin = FiscalYear.current.start_date
    five_fy_begin = fy_begin.advance years: -4

    {"#{month_begin.strftime("%B")} To Date" => stats(month_begin..today), 
    "#{last_month.strftime("%B")}" => stats(last_month..last_month.end_of_month), 
    "FYTD" => stats(fy_begin..today), 
    "5 Years" => stats(five_fy_begin..today)}
  end

  def map_json_for(incidents)
    incidents.joins{chapter}.pluck(:incident_number, :lat, :lng, :num_adults, :num_children, :status, "roster_chapters.url_slug").map do |inc|
      {id: inc[0], lat: inc[1], lng: inc[2], clients: [inc[3], inc[4]].compact.sum, status: inc[5], url: incidents_chapter_incident_path(inc[6], inc[0])}
    end
  rescue ActiveRecord::ThrowResult
    []
  end
end
