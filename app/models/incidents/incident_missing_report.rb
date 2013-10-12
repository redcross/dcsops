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

  def additional_notifications
    county = @incident.area_id
    groups = Scheduler::ShiftGroup.current_groups_for_chapter(@incident.chapter, @incident.created_at)
    assignments = groups.map{|grp| Scheduler::ShiftAssignment.joins{shift}.where{(shift.shift_group_id == grp) & (date == grp.start_date) & (shift.county_id == county) & (shift.dispatch_role != nil)}.to_a }.flatten.compact
    assignments.map(&:person)
  end

  def fire_notifications
    notify do |person|
      Incidents::IncidentsMailer.no_incident_report(@incident, person).deliver
    end
  end
end