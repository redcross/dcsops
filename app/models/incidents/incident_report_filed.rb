class Incidents::IncidentReportFiled
  include Notifier

  self.notification_type = 'incident_report'
  self.role_grant_name = 'receive_incident_report'

  def initialize(incident, is_new)
    @incident = incident
    @is_new = is_new
  end

  def save
    if incident.valid_incident?
      fire_notifications
    end
  end

  def role_scope
    @incident.area_id
  end

  def notification_scope
    @incident.area_id
  end

  def fire_notifications
    notify do |person|
      Incidents::IncidentsMailer.incident_report_filed(@incident, person, @is_new).deliver
    end
  end
end