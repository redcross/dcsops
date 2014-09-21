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
    send_update({refresh: tabs, chapter: chapter.id, incident: (incident && incident.id)})
  end

  def send_update value
    client = PubnubClient.client
    client.publish channel: channel_name, message: value, callback: ->msg{ puts "Update sent #{msg.inspect}"}
  end

  def channel_name
    "incident-updates"
  end

end