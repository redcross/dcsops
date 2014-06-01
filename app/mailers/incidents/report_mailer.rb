class Incidents::ReportMailer < ActionMailer::Base
  include MailerCommon
  include Exposure

  helper Incidents::ReportMailerHelper

  default from: "DCSOps <incidents@dcsops.org>"

  def self.report(chapter, recipient)
    start_date = chapter.time_zone.today.at_beginning_of_week.last_week
    end_date = start_date.next_week.yesterday
    self.report_for_date_range(chapter, recipient, start_date..end_date)
  end

  def report_for_date_range(chapter, recipient, date_range)
    @chapter = chapter
    @person = recipient
    @date_range = date_range

    fiscal = FiscalYear.for_date(@date_range.first)

    scope = Incidents::Incident.valid.for_chapter(chapter)
    
    @incident_scope = date_scope(scope, date_range).order{date}.includes{responder_assignments.person}
    @incidents = @incident_scope.map{|i| Incidents::IncidentPresenter.new i}
    @weekly_stats = date_scope(scope, date_range).incident_stats
    @yearly_stats = scope.where{date.in(fiscal.range)}.incident_stats

    tag :incidents, :weekly_report
    mail to: format_address(recipient), subject: subject, template_name: 'report'
  end

private

  attr_reader :chapter, :person, :incidents
  helper_method :chapter, :person, :incidents

  def subject
    [title, subtitle].join(" - ")
  end

  helper_method :subtitle, :title
  def title
    "#{chapter.short_name} Disaster Operations Report"
  end

  def date_scope(scope, date_range)
    if chapter.incidents_report_use_response_date
      scope.where{response_date.in(date_range)}
    else
      scope.where{date.in(date_range)}
    end
  end

  def subtitle
    size = @date_range.last - @date_range.first + 1
    if size == 1
      @date_range.first.to_s :dow_long
    elsif size == 7 && @date_range.first.wday == 1
      "Week of #{@date_range.first.to_s :mdy}"
    else
      "#{@date_range.first.to_s :dow_short} to #{@date_range.last.to_s :dow_short}"
    end
  end

  expose(:sections_to_render) {
    ['incident_table', 'incident_statistics', 'deployments_summary']
  }

  def deployments
    ignore = chapter.incidents_report_dro_ignore_array

    Incidents::Deployment.for_chapter(chapter).seen_since(@date_range.first)
                          .includes{[disaster, person.counties]}
                          .where{ disaster.dr_number.not_like_any(ignore) }
                          .order{ date_first_seen.desc }
                          .uniq{|a| [a.person_id, a.disaster_id] }
                          .group_by{|a| a.disaster.title }
  end

  expose(:detailed_deployments) {
    deployments.map do |name, deps|
      [name, deps.sort_by{|a| [a.person.counties.first.try(:name) || '', a.person.last_name] }]
    end
  }

  expose(:summary_deployments) {
    deployments.map{|name, responders| [name, responders.count]}
  }

  def responder_assignments
    Incidents::ResponderAssignment.where{incident_id.in(my{@incidents.map(&:id)})}.was_available
  end

  expose(:responders_summary_count) {
    responder_assignments.pluck(:person_id).flatten.uniq.count
  }

  expose(:responders_distance) {
    responder_assignments.joins{person.outer}.includes{[incident, person.outer]}
                          .where{{person: sift(:with_position)}}
                          .select{|ass| ass.on_scene }
                          .map{|ass| ass.incident.distance_to ass.person}
                          .map{|dist| [50, dist * 2].min}.sum.round
  }

  expose(:incident_statistics) {
    @incident_scope.count_resources(chapter.incidents_resources_tracked_array)
  }

  expose(:map_width) { 250 }
  expose(:map_height) { (map_width * 1.8).to_i }

end
