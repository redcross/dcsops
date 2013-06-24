class Incidents::DispatchLogUpdated
  def initialize(dispatch_log)
    @dispatch_log = dispatch_log
  end

  def save
    if @dispatch_log.incident
      fire_notifications
    end
  end

  def fire_notifications
    county = @dispatch_log.incident.county_id

    type = @dispatch_log.delivered_at ? 'incident_dispatch' : 'new_incident'

    subscriptions = Incidents::NotificationSubscription.for_county(county).for_type(type)
    subscriptions.each do |sub|
      Incidents::IncidentsMailer.incident_dispatched(@dispatch_log.incident, sub.person).deliver
    end
  end
end