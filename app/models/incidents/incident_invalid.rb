class Incidents::IncidentInvalid
  include Notifier

  self.notification_type = 'incident_report'
  self.role_grant_name = 'receive_incident_report'

  def initialize(incident)
    @incident = incident
  end

  def save
    if @incident.save
      fire_notifications
    end
  end

  def role_scope
    @incident.area_id
  end

  def notification_scope
    @incident.area_id
  end

  def chapter
    @incident.chapter
  end

  def fire_notifications
    notify do |person|
      Incidents::IncidentsMailer.incident_invalid(@incident, person).deliver
    end
  end
end