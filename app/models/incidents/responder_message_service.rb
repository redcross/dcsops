class Incidents::ResponderMessageService
  include Incidents::ResponderMessagesHelper, ApplicationHelper # to get short_url
  attr_reader :incoming, :response, :assignment
  def initialize(message)
    @incoming = message
  end

  def reply
    @response = Incidents::ResponderMessage.new chapter: incoming.chapter, person: incoming.person

    @assignment = open_assignment_for_person(incoming.person)
    unless @assignment
      response.message = "You are not currently assigned to an incident response."
      return response
    end

    incoming.incident = response.incident = assignment.incident
    handle_command incoming.message.downcase
    incoming.save

    response
  end

  def open_assignment_for_person(person)
    Incidents::ResponderAssignment.joins{incident}.where{incident.status == 'open'}.for_person(person).open.order{created_at.desc}.first
  end

  def handle_command command
    incoming.acknowledged = true
    case command
    when /incident/ then handle_incident_info
    when /on scene/, /arrived/ then handle_on_scene
    when /departed/ then handle_departed_scene
    when /map/, /directions/, /address/ then handle_incident_map
    when /responders/ then handle_responders
    when /commands/ then handle_help
    else incoming.acknowledged = false
    end
  end

  def handle_help
    response.message = "DCSOps SMS Commands: MAP for map link, RESPONDERS for contact info, ARRIVED to record you're on scene, DEPARTED to record you've left"
  end

  def handle_on_scene
    if !assignment.on_scene_at
      assignment.on_scene!
      response.message = "You're now on scene"
    else
      response.message = "You're already on scene"
    end
  end

  def handle_departed_scene
    if !assignment.departed_scene_at && assignment.on_scene_at
      assignment.departed_scene!
      response.message = "You've now departed the scene."
    elsif assignment.departed_scene_at
      response.message = "You've already departed the scene."
    else
      response.message = "You aren't on scene yet!"
    end
  end

  def handle_incident_map
    response.message = map_link_message
  end

  def handle_responders
    response.message = responder_info_message(incoming.person)
  end

  def handle_incident_info
    response.message = "Incident #{incident.incident_number} Type: #{incident.humanized_incident_type}.  You are assigned as: #{assignment.humanized_role}"
  end

  def incident
    @incident ||= Incidents::IncidentPresenter.new(assignment.incident)
  end
end
