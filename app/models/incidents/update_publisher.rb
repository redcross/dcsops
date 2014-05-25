class Incidents::UpdatePublisher
  attr_reader :chapter, :incident
  def initialize(chapter, incident=nil)
    @chapter = chapter
    @incident = incident
  end

  def publish_responders
    update_tabs 'responders', 'timeline'
  end

  def publish_incoming
    update_tabs 'incoming'
  end

  def publish_recruitment
    update_tabs 'recruitment'
  end

  def publish_details
    update_tabs 'details'
  end

  def publish_timeline
    update_tabs 'timeline'
  end

  protected

  def update_tabs *tabs
    tabs << 'changes'
    send_update({refresh: tabs, incident: (incident && incident.id)})
  end

  def send_update value
    client = GoInstantClient.client
    pp value
    client.send_to_channel chapter_room_name, channel_name, value
  end

  def room_name
    "incident-#{incident.id}"
  end

  def chapter_room_name
    "chapter-#{chapter.id}"
  end

  def channel_name
    "updates"
  end

end