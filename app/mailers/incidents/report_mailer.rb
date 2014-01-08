class Incidents::ReportMailer < ActionMailer::Base
  include MailerCommon
  include Exposure

  default from: "ARCBA DAT <incidents@arcbadat.org>"

  def self.report(chapter, recipient)
    start_date = chapter.time_zone.today.at_beginning_of_week.last_week
    end_date = start_date.next_week.yesterday
    self.report_for_date_range(chapter, recipient, start_date, end_date)
  end

  def report_for_date_range(chapter, recipient, start_date, end_date)
    @chapter = chapter
    @person = recipient
    @start_date = start_date
    @end_date = end_date

    fiscal = FiscalYear.for_date(@start_date)

    scope = Incidents::Incident.valid.joins{self.chapter}.where{chapter_id == chapter}
    
    @incidents = scope.where{date.in(my{@start_date..@end_date})}.order{date}.includes{responder_assignments.person}
    @weekly_stats = scope.where{date.in(my{@start_date..@end_date})}.incident_stats
    @yearly_stats = scope.where{(date >= fiscal.start_date) & (date <= my{@end_date})}.incident_stats

    tag :incidents, :weekly_report
    mail to: format_address(recipient), subject: [title, subtitle].join(" - "), template_name: 'report'
  end

private

  attr_reader :chapter, :person, :start_date, :end_date
  helper_method :chapter, :person, :start_date, :end_date

  expose(:title) {
    "#{chapter.short_name} Disaster Operations Report"
  }

  expose(:subtitle) {
    "Week of #{start_date.to_s :mdy}"
  }

  expose(:sections_to_render) {
    ['incident_table', 'incident_statistics', 'deployments_summary']
  }

  expose(:detailed_deployments) {
    ignore = chapter.incidents_report_dro_ignore || ""
    drs_to_ignore = ignore.split(',').select(&:present?).map{|d| d + '%'}

    Incidents::Deployment.joins{person}.where{person.chapter_id == my{@chapter}}
                          .includes{person.counties}
                          .where{date_last_seen >= my{@start_date}}
                          .where{(dr_name.not_like_any(drs_to_ignore))}
                          .uniq.to_a
                          .group_by{|a| [a.person_id, a.dr_name] }.map{|_, deployments| deployments.last}
                          .sort_by{|a| a.person.counties.first.try(:name) || '' }
                          .reduce({}) { |hash, d| hash[d.dr_name] ||= []; hash[d.dr_name] << d; hash}
  }

  expose(:summary_deployments) {
    detailed_deployments.map{|name, responders| [name, responders.count]}
  }

  expose(:responders_summary_count) {
    Incidents::ResponderAssignment.where{incident_id.in(my{@incidents})}.was_available
                                  .pluck(:person_id).flatten.uniq.count
  }

  expose(:incident_statistics) {
    incident_ids = @incidents.map(&:id)
    val = {}

    chapter.incidents_resources_tracked_array.each do |res|
      val[res] =  @incidents.joins{dat_incident}.reorder('value')
                            .select{sum(coalesce(cast(dat_incident.resources.op('->', res).as(integer)), 0)).as(value)}
                            .first.value
    end

    val
  }

  expose(:responders_distance) {
    @incidents.flat_map do |inc|
      loc = Geokit::LatLng.new inc.lat, inc.lng
      inc.responder_assignments.select(&:was_available)
          .select{|ass| ass.person.lat && ass.person.lng && ass.person.lat != 0 && ass.person.lng != 0}
          .map{|ass| pt = Geokit::LatLng.new(ass.person.lat, ass.person.lng); [50, loc.distance_to(pt) * 2].min }
    end.sum.round
  }

  expose(:map_width) { 250 }
  expose(:map_height) { (map_width * 1.8).to_i }

  helper_method :static_maps_url
  def static_maps_url(retina=false, width=map_width, height=map_height)
    size = "#{width}x#{height}"
    "http://maps.googleapis.com/maps/api/staticmap?visual_refresh=true&sensor=false&size=#{size}&markers=#{URI::encode incidents_marker_param}&scale=#{retina ? '2' : '1'}&key=AIzaSyBabBKA3eRH_Pj1UdHEvzISS0crsOScsf4"
  end

  def image_content
    uri = URI(static_maps_url)
    resp = Net::HTTP.get_response uri
    { content_type: resp['Content-Type'], content: resp.body }
  end

  def incidents_marker_param
    "|" + @incidents.map{|i| [i.lat.to_s, i.lng.to_s].join(",")}.join("|")
  end
end
