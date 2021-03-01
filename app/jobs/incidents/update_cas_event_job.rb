class Incidents::UpdateCasEventJob
  def self.enqueue *args
    Delayed::Job.enqueue self.new(*args)
  end

  attr_reader :incident_id

  def initialize incident_id
    @incident_id = incident_id
  end

  def incident
    @incident ||= Incidents::Incident.find(incident_id)
  end

  def region
    incident.region
  end

  def client
    @client ||= Rccare::Client.new()
  end

  def cas_configured?
    region.cas_host.present? && region.cas_username.present? && region.cas_password.present?
  end

  def perform
    event_number = incident.cas_event_number
    events = event_number.present? && client.events(event_number)
    if events && events.size > 0
      incident.rccare_event_id = events.first.Id
      incident.cas_event_number = events.first.Name
    else
      incident.rccare_event_id = nil
    end
    incident.save!
    publish_update
  end

  def publish_update
    Incidents::UpdatePublisher.new(region, incident).publish_details
  end

end