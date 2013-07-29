class Incidents::IncidentReportFiled
  include Notifier

  self.notification_type = 'incident_report'
  self.role_grant_name = 'receive_incident_report'

  def initialize(incident)
    @incident = incident
  end

  def save
    fire_notifications
  end

  def role_scope
    @incident.county_id
  end

  def notification_scope
    @incident.county_id
  end

  def fire_notifications
    notify do |person|
      Incidents::IncidentsMailer.incident_report_filed(@incident, person).deliver
    end
  end
end