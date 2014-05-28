module Incidents::GoInstantHelper
  def goinstant_page_setup(person, rooms=[])
    token = signature_for_person_rooms person, rooms
    javascript_include_tag("https://cdn.goinstant.net/v1/platform.min.js") <<
    javascript_tag(<<-JS)
      window.goinstantConnectionPromise = goinstant.connect(#{goinstant_app_url.to_json}, {user: #{token.to_json}})
    JS
  end

  def goinstant_app_url
    ENV['GOINSTANT_CONNECT_URL']
  end

  def goinstant_room_for_chapter(chapter)
    "chapter-#{chapter.id}"
  end

  def goinstant_room_for_incident(incident)
    "incident-#{incident.id}"
  end

  def signature_for_person_rooms(person, rooms)
    rooms ||= []
    rooms << 'verified'
    GoInstantClient.sign_token person.id, person.full_name, rooms
  end

  def chapter_goinstant_setup chapter=nil
    chapter ||= current_chapter
    goinstant_setup chapter
  end

  def incidents_goinstant_setup incident=nil
    incident ||= resource
    goinstant_setup incident.chapter, incident
  end

  def goinstant_setup chapter, incident=nil
    incident_setup = "window.incidentInstantController.setIncident(#{incident.id.to_json});" if incident
    room = goinstant_room_for_chapter(chapter)
    enable_chat = chapter.incidents_enable_chat && can?(:read, :chat)
    rooms = [room]
    rooms << "#{room}-chat" if enable_chat

    js = <<-JS
      $(function() {
        window.incidentInstantController = new IncidentInstantController(goinstantConnectionPromise);
        #{incident_setup}
        window.incidentInstantController.monitorRoom(#{room.to_json});
      })
    JS
    goinstant_page_setup(current_user, rooms) <<
    javascript_tag(js) <<
    (enable_chat ? chat_setup(chapter) : '')
  end

  def chat_setup chapter=nil
    javascript_include_tag("https://cdn.goinstant.net/widgets/chat/latest/chat.min.js") <<
    stylesheet_link_tag("https://cdn.goinstant.net/widgets/chat/latest/chat.css") <<
    javascript_tag(<<-JS)
      $(function() {
        window.incidentInstantController.startChat(#{(goinstant_room_for_chapter(chapter)+"-chat").to_json})
      })
    JS
  end

end