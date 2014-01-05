class Incidents::IncidentMissingReport
  include Notifier

  self.notification_type = 'missing_report'
  self.role_grant_name = 'receive_incident_missing_report'

  def initialize(incident)
    @incident = incident
  end

  def save
    fire_notifications
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

  def additional_notifications
    county = @incident.area_id
    assignments = Scheduler::SchedulerService.new(@incident.chapter).dispatch_assignments(time: @incident.created_at, area: county)
    assignments.map(&:person)
  end

  def fire_notifications
    notify do |person|
      Incidents::IncidentsMailer.no_incident_report(@incident, person).deliver
    end
  end
end