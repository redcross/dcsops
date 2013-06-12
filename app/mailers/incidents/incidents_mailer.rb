class Incidents::IncidentsMailer < ActionMailer::Base
  default from: "ARCBA DAT <incidents@arcbadat.org>"

  # Subject can be set in your I18n file at config/locales/en.yml
  # with the following lookup:
  #
  #   en.incidents.incidents_mailer.weekly.subject
  #
  def weekly(chapter)
    @chapter = chapter
    @start_date = chapter.time_zone.today.at_beginning_of_week.last_week
    @end_date = @start_date.next_week.yesterday
    @incidents = Incidents::Incident.all.joins{dat_incident}#Incidents::Incident.where{date.in(@start_date..@end_date)}.order{date}
    @weekly_stats = Incidents::Incident.where{date.in(@start_date..@end_date)}.incident_stats
    @yearly_stats = Incidents::Incident.where{date >= '2012-07-01'}.incident_stats

    @subtitle = "Week of #{@start_date.to_s :mdy}"

    @title = "ARCBA Disaster Operations Report - #{@subtitle}"

    mail to: "John Laxson <jlaxson@mac.com>", subject: @title
  end

  # Subject can be set in your I18n file at config/locales/en.yml
  # with the following lookup:
  #
  #   en.incidents.incidents_mailer.no_incident_report.subject
  #
  def no_incident_report(incident)
    @incident = incident

    mail to: "John Laxson <jlaxson@mac.com>", subject: "Missing Incident Report"
  end

  # Subject can be set in your I18n file at config/locales/en.yml
  # with the following lookup:
  #
  #   en.incidents.incidents_mailer.orphan_cas.subject
  #
  def orphan_cas
    @greeting = "Hi"

    mail to: "to@example.org"
  end

  private

  helper_method :static_maps_url
  def static_maps_url
    "http://maps.googleapis.com/maps/api/staticmap?visual_refresh=true&sensor=false&size=300x600&markers=#{URI::encode incidents_marker_param}&scale=2"
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
