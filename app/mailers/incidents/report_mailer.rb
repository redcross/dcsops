class Incidents::ReportMailer < ActionMailer::Base
  include MailerCommon
  include Exposure

  helper Incidents::ReportMailerHelper

  default from: "DCSOps <incidents@dcsops.org>"

  def self.report(scope, recipient)
    start_date = scope.time_zone.today.at_beginning_of_week.last_week
    end_date = start_date.next_week.yesterday
    self.report_for_date_range(scope, recipient, start_date..end_date)
  end

  def report_for_date_range(scope, recipient, date_range)
    @scope = scope
    @person = recipient
    @date_range = date_range

    fiscal = FiscalYear.for_date(@date_range.first)

    rel = Incidents::Incident.valid.for_region(scope.all_regions)
    
    @incident_scope = date_scope(rel, date_range).order(:date).includes(responder_assignments: :person)
    @incidents = @incident_scope.map{|i| Incidents::IncidentPresenter.new(i) }
    @weekly_stats = date_scope(rel, date_range).incident_stats
    @yearly_stats = rel.where(date: fiscal.range).incident_stats

    tag :incidents, :weekly_report
    mail to: format_address(recipient), subject: subject, template_name: 'report'
  end

private

  attr_reader :scope, :person, :incidents
  helper_method :scope, :person, :incidents

  def subject
    [title, subtitle].join(" - ")
  end

  helper_method :subtitle, :title
  def title
    "#{scope.short_name} Disaster Operations Report"
  end

  def date_scope(scope, date_range)
    scope.where(date: date_range)
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
    ignore = scope.report_dro_ignore_array
    regions = scope.all_regions
    Incidents::Deployment.for_region(regions).seen_since(@date_range.first)
                          .preload(:disaster, person: :shift_territories)
                          .joins(:disaster)
                          .where.not(incidents_disasters: { dr_number: ignore })
                          .order(date_first_seen: :desc)
                          .to_a
                          .uniq{|a| [a.person_id, a.disaster_id] }
                          .group_by{|a| a.disaster.title }
  end

  expose(:detailed_deployments) {
    deployments.map do |name, deps|
      [name, deps.sort_by{|a| [a.person.shift_territories.first.try(:name) || '', a.person.last_name] }]
    end
  }

  expose(:summary_deployments) {
    deployments.map{|name, responders| [name, responders.count]}
  }

  def responder_assignments
    Incidents::ResponderAssignment.where(incident_id: @incidents.map(&:id)).was_available
  end

  expose(:responders_summary_count) {
    responder_assignments.pluck(:person_id).flatten.uniq.count
  }

  expose(:responders_distance) {
    responder_assignments.driving_distance
  }

  expose(:incident_statistics) {
    resources = scope.all_regions.flat_map(&:incidents_resources_tracked_array).uniq
    @incident_scope.count_resources(resources)
  }

  expose(:incident_counts) {
    hash = @incidents.select{|i| i.county.present? }.sort_by{|i| [i.state, i.county]}.group_by(&:county_state)
    hash.map {|title, coll| [title, coll.count]}
  }

  expose(:map_width) { 250 }
  expose(:map_height) { (map_width * 1.8).to_i }

end
