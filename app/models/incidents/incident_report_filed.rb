class Incidents::IncidentReportFiled
  def initialize(incident)
    @incident = incident
  end

  def save
    if @incident.save
      fire_notifications
    end
  end

  def fire_notifications
    county = @incident.county_id

    subscriptions = Incidents::NotificationSubscription.for_county(county).for_type('incident_report')
    subscriptions.each do |sub|
      Incidents::IncidentsMailer.incident_report_filed(@incident, sub.person).deliver
    end
  end
end