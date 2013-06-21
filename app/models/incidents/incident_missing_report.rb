class Incidents::IncidentMissingReport
  def initialize(incident)
    @incident = incident
  end

  def save
    fire_notifications
  end

  def fire_notifications
    county = @incident.county_id

    subscriptions = Incidents::NotificationSubscription.for_county(county).for_type('missing_report')
    subscriptions.each do |sub|
      Incidents::IncidentsMailer.no_incident_report(@incident, sub.person).deliver
    end

    if county
      groups = Scheduler::ShiftGroup.current_groups_for_chapter(@incident.chapter, @incident.created_at)

      assignments = groups.map{|grp| Scheduler::ShiftAssignment.joins{shift}.where{(shift.shift_group_id == grp) & (date == grp.start_date) & (shift.county_id == county) & (shift.dispatch_role != nil)}.to_a }.flatten.compact

      assignments.each do |ass|
        Incidents::IncidentsMailer.no_incident_report(@incident, ass.person).deliver
      end
    end
  end
end