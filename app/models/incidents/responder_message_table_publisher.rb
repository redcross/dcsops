class Incidents::ResponderMessageTablePublisher
  attr_reader :incident
  def initialize(incident)
    @incident = incident
  end

  def publish_responders
    send_update({refresh:".assigned-table"})
  end

  def publish_incoming
    send_update({refresh:".incoming-table"})
  end

  def publish_recruitment
    send_update({refresh:".responders-table"})
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

    def render_assigned_table
      render partial: "incidents/responders/assigned_table", locals: {collection: incident.all_responder_assignments}
    end

    def render_responders_table
      collection = incident.all_responder_assignments
      render partial: "incidents/responders/responders_table", locals: {collection: collection, service: Incidents::RespondersService.new(incident, collection, ignore_area_scheduled: true, ignore_area_flex: true)}
    end

    attr_reader :incident
    alias_method :parent, :incident
    helper_method :incident, :parent
    helper do
      def can? *args
        true
      end
    end
  end
end