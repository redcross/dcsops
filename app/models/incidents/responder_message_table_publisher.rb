class Incidents::ResponderMessageTablePublisher
  attr_reader :incident
  def initialize(incident)
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
    send_update({refresh: tabs})
  end

  def send_update value
    client = GoInstantClient.client
    client.send_to_channel room_name, channel_name, value
  end

  def room_name
    "incident-#{incident.id}"
  end

  def channel_name
    "updates"
  end

end