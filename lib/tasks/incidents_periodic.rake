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
      if Date.current.wday == 1 or ENV['FORCE_WEEKLY_REPORT'] == '1'
        subscriptions = Incidents::NotificationSubscription.for_type('weekly').includes{person.chapter}
        subscriptions.each do |sub|
          Incidents::IncidentsMailer.weekly(sub.person.chapter, sub.person).deliver
        end
      end
    end
  end

  task :get_deployments => :environment do
    Raven.capture do
      Roster::Chapter.where{vc_username != nil}.each do |chapter|
        VcQuery.get_deployments chapter
      end
    end
  end
end