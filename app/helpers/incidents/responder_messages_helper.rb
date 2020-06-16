module Incidents::ResponderMessagesHelper
  def map_link_message
    "Incident Location: #{incident.full_address}.  View in Map: #{short_url(incident.map_url)}"
  end

  def timeline_entry_message
    log = incident.event_logs.order(event_time: :desc).note.first
    if log
      "Incident Note: #{log.message}"
    end
  end

  def responder_info_message(exclude_person=nil)
    assignments = incident.all_responder_assignments.was_available.where(departed_scene_at: nil)
    if exclude_person
      assignments = assignments.reject{|a| a.person == exclude_person}
    end

    assignment_str = assignments.map{|a| "#{a.person.full_name} #{a.person.primary_phone} (#{a.humanized_role})"}.join ", "

    "Responders: #{assignment_str}"
  end
end