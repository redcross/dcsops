class Incidents::NewDispatchService

  def self.create call_log
    new(call_log).create
  end

  def initialize call_log
    @call_log = call_log
  end

  attr_reader :call_log, :incident

  def create
    create_incident
    send_notifications
    assign_contact
  end

  def create_incident
    @incident = Incidents::Incident.create! do |i|
      i.status = 'open'
      [:region_id, :response_territory_id, :incident_type, :address, :city, :county, :state, :zip, :lat, :lng].each do |attr|
        i[attr] = call_log[attr]
      end
      i.date = i.region.time_zone.today
    end
    call_log.update incident_id: incident.id

    @incident.event_logs.create! event: 'dispatch_received', message: summary_message, event_time: incident.region.time_zone.now
  end

  def send_notifications
    Incidents::Notifications::Notification.create_for_event incident, 'new_incident', message: summary_message
  end

  def summary_message
    <<-MSG
Contact Name: #{call_log.contact_name}
Contact Number: #{call_log.contact_number}
# Displaced: #{call_log.num_displaced}
Services Requested: #{call_log.services_requested}
    MSG
  end
    
  def assign_contact
    Incidents::DispatchService.new(incident).assign_contact
  end
end