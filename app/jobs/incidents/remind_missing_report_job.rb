class Incidents::RemindMissingReportJob

  def self.enqueue
    new.perform
  end

  def perform
    threshold = 12.hours.ago
    now = 5.minutes.ago
    Incidents::Incident.valid
      .left_outer_joins(:dat_incident)
      .joins(:dispatch_log)
      .where(dat_incident: { id: nil })
      .where('created_at < ?', threshold)
      .where(where(last_no_incident_warning: nil).or(where('last_no_incident_warning < ?', threshold)))
      .readonly(false)
      .each do |inc|
      inc.update_attribute :last_no_incident_warning, now
      Incidents::Notifications::Notification.create_for_event inc, 'incident_missing_report'
    end
  end

end