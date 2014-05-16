class Incidents::ResponderMessageTablePublisher
  attr_reader :incident
  def initialize(incident)
    @incident = incident
  end

  def publish_responders
    table = Renderer.new(incident).render_responders_table
    send_update({name:"assigned-table", html: table})
  end

  def publish_incoming
    table = Renderer.new(incident).render_incoming_table
    send_update({name:"messages-table", html: table})
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

  class Renderer < AbstractController::Base
    include AbstractController::Rendering
    # I didn't need layouts, translation or assetpaths, YMMV
    include AbstractController::Helpers
    include Rails.application.routes.url_helpers 

    helper Incidents::RespondersHelper

    self.view_paths = Rails.application.config.paths["app/views"]

    def initialize incident
      @incident = incident
    end

    def render_incoming_table
      render :partial => "incidents/responder_messages/incoming_table"
    end

    def render_responders_table
      render partial: "incidents/responders/assigned_table", locals: {collection: incident.all_responder_assignments}
    end

    attr_reader :incident
    alias_method :parent, :incident
    helper_method :incident, :parent
  end
end