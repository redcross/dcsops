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

  def chapter
    incident.chapter
  end

  def client
    @client ||= Cas::Client.new(chapter.cas_host, chapter.cas_username, chapter.cas_password)
  end

  def cas_configured?
    chapter.cas_host.present? && chapter.cas_username.present? && chapter.cas_password.present?
  end

  def perform
    return unless cas_configured?

    event_number = incident.cas_event_number
    cas_event = client.events.find_by_event_number(event_number)
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
    Incidents::UpdatePublisher.new(chapter, incident).publish_details
  end

end