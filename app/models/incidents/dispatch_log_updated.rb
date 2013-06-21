class Incidents::DispatchLogUpdated
  def initialize(dispatch_log)
    @dispatch_log = dispatch_log
  end

  def save
    if @dispatch_log.old_changes.keys.include? 'delivered_at' and @dispatch_log.delivered_at and @dispatch_log.incident
      fire_notifications
    end
  end

  def fire_notifications
    county = @dispatch_log.incident.county_id

    subscriptions = Incidents::NotificationSubscription.for_county(county).for_type('incident_dispatch')
    subscriptions.each do |sub|
      Incidents::IncidentsMailer.incident_dispatched(@dispatch_log.incident, sub.person).deliver
    end
  end
end