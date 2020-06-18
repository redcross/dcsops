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
    @client ||= Cas::Client.new(region.cas_host, region.cas_username, region.cas_password)
  end

  def cas_configured?
    region.cas_host.present? && region.cas_username.present? && region.cas_password.present?
  end

  def perform
    return unless cas_configured?

    event_number = incident.cas_event_number
    cas_event = event_number.present? && client.events.find_by_event_number(event_number)
    if cas_event
      incident.cas_event_id = cas_event['id']
      incident.cas_event_number = cas_event['local_event_number']
    else
      incident.cas_event_id = nil
    end
    incident.save!
    publish_update
  end

  def publish_update
    Incidents::UpdatePublisher.new(region, incident).publish_details
  end

end