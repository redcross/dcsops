class Incidents::IncidentCreated
  include Notifier
  self.notification_type = 'new_incident'
  self.role_grant_name = 'receive_new_incident'


  def initialize(incident)
    @incident = incident
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

  def save
    if @incident.save
      fire_notifications
    end
  end

  def fire_notifications
    notify do |person|
      Incidents::IncidentsMailer.new_incident(@incident, person).deliver
    end
  end

end