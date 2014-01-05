class Incidents::DispatchLogUpdated
    include Notifier

  self.notification_type = 'incident_report'
  self.role_grant_name = 'receive_incident_report'

  def initialize(dispatch_log)
    @dispatch_log = dispatch_log
  end

  def save
    if @dispatch_log.incident
      fire_notifications
    end
  end

  def role_scope
    @dispatch_log.incident.area_id
  end

  def notification_scope
    @dispatch_log.incident.area_id
  end

  def notification_type
    @dispatch_log.delivered_at ? 'incident_dispatch' : 'new_incident'
  end

  def self.role_grant_name
    "receive_#{notification_type}"
  end

  def chapter
    @dispatch_log.incident.chapter
  end

  def fire_notifications
    notify do |person|
      Incidents::IncidentsMailer.incident_dispatched(@dispatch_log.incident, person).deliver
    end
  end
end