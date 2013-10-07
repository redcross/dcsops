class Incidents::HomeController < Incidents::BaseController

  def root
  end

  def operations

  end

  def map
    @search = Incidents::Incident.search(params[:q])
    @incidents = @search.result.for_chapter(current_chapter).valid.where{(lat != nil) & (lng != nil) & (lat.in 37.165368468295085..38.251787162859415) & (lng.in(-123.84274052031253..-121.45321415312503))}
  end

  private

  helper_method :recent_incidents, :map_json_for
  expose(:recent_incidents) {Incidents::Incident.for_chapter(current_chapter).valid.includes{dat_incident}.order{incident_number.desc}.order{date.desc}.limit(15)}

  def map_json_for(incidents)
    incidents.map do |inc|
      {id: inc.incident_number, lat: inc.lat, lng: inc.lng, clients: [inc.num_adults, inc.num_children].compact.sum, status: inc.incident_status}
    end
  end

  def is_subscribed_weekly
    Incidents::NotificationSetting.where{(person_id==my{current_user}) & (notification_type == 'weekly')}.exists?
  end

  helper_method :incident_stats_boxes
  def incident_stats_boxes
    month_begin = current_chapter.time_zone.today.at_beginning_of_month
    last_month = month_begin.last_month

    fy_begin = month_begin.advance months: (month_begin.month >= 7) ? -(month_begin.month - 7) : -(month_begin.month + 6)

    five_fy_begin = fy_begin.advance years: -4

    {"#{month_begin.strftime("%B")} To Date" => Incidents::Incident.unscoped.for_chapter(current_chapter).where{date >= month_begin}.incident_stats, 
    "#{last_month.strftime("%B")}" => Incidents::Incident.unscoped.for_chapter(current_chapter).where{date.in(last_month..(last_month.at_end_of_month))}.incident_stats, 
    "FYTD" => Incidents::Incident.for_chapter(current_chapter).where{date >= fy_begin}.incident_stats, 
    "5 Years" => Incidents::Incident.for_chapter(current_chapter).where{date >= five_fy_begin}.incident_stats}
  end
end
