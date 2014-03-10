namespace :incidents_periodic do
  task :send_reminders => [:send_missing_incident_report]

  task :send_no_incident_report => :environment do
    Raven.capture do
      threshold = 12.hours.ago
      now = 5.minutes.ago
      Incidents::Incident.valid.joins{[dat_incident.outer, dispatch_log]}.where{(dat_incident.id == nil) & (created_at < threshold) & 
          ((last_no_incident_warning == nil) | (last_no_incident_warning < threshold))}.readonly(false).each do |inc|
        inc.update_attribute :last_no_incident_warning, now
        Incidents::IncidentMissingReport.new(inc).save
      end
    end
  end

  task :send_weekly_report => :environment do
    Raven.capture do
      Roster::Chapter.with_incidents_report_send_automatically_value(true).each do |chapter|
        today = chapter.time_zone.today
        subscriptions = Incidents::NotificationSubscription.for_type('report').for_chapter(chapter).to_send_on(today).includes{person.chapter}.with_active_person.readonly(false)
        subscriptions.each do |sub|
          Incidents::ReportMailer.report_for_date_range(sub.person.chapter, sub.person, sub.range_to_send).deliver
          sub.update_attribute :last_sent, today
        end
      end
    end
  end

  task :get_deployments => :environment do
    Raven.capture do
      Roster::Chapter.where{vc_username != nil}.each do |chapter|
        Vc::Deployments.get_deployments chapter
      end
    end
  end
end