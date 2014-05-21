class Incidents::ResponderMessagesController < Incidents::EditPanelController

  self.panel_name='responders'
  custom_actions resource: [:acknowledge], collection: [:index]
  responders :partial

  def acknowledge
    if params[:save_in_timeline]
      log_message = "SMS From #{resource.person.full_name}: #{resource.message}"
      parent.event_logs.create event: 'note', event_time:resource.created_at, person: current_user, message: log_message
    end
    resource.update_attribute :acknowledged, true

    if params[:commit] == 'Reply'
      redirect_to action: :new, recipient: resource.person_id
    else
      render action: :update
    end


    Incidents::ResponderMessageTablePublisher.new(parent).publish_incoming
  end

  def valid_partial? partial
    partial == 'incoming_table'
  end

  protected

  def create_resource resource
    if resource.person_id.nil?
      to_send = all_recipients.map(&:person).map{|recipient| resource.dup.tap{|r| r.person = recipient }}

      # Just make sure everything but person is good
      resource.valid?
      resource.errors.delete :person_id
      resource.errors.delete :person
      return false unless resource.errors.blank?
    else
      to_send = [resource]
    end

    if to_send.all?{|msg| super(msg)}
      to_send.each{|msg| send_resource msg}
      true
    else
      false
    end
  end

  def all_recipients
    incident.all_responder_assignments.select{|a| a.person.sms_addresses.present? && a.departed_scene_at == nil}
  end
  helper_method :all_recipients

  def send_resource resource
    client = Incidents::SMSClient.new(incident.chapter)
    client.send_message(resource)
  end

  def build_resource
    @responder_message = Incidents::ResponderMessage.new *resource_params
  end 

  def build_resource_params
    attrs = params.fetch(:incidents_responder_message, {}).permit(:person_id, :message)
    attrs[:person_id] ||= params[:recipient]
    attrs[:incident_id] = incident.id
    attrs[:chapter_id] = incident.chapter_id
    [attrs]
  end

  def incident
    @real_incident ||= Incidents::IncidentPresenter.new(parent)
  end
  helper_method :incident

  def after_create_url
    incidents_incident_responders_path(incident)
  end

end