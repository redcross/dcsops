class Incidents::ResponderRecruitmentsController < Incidents::EditPanelController
  belongs_to_incident
  self.panel_name='responders'

  protected

  def create_resource resource
    if super(resource)
      send_message resource
      Incidents::UpdatePublisher.new(incident.chapter, incident).publish_recruitment
      true
    else
      false
    end
  end

  def all_recipients
    incident.all_responder_assignments.select{|a| a.person.sms_addresses.present? && a.departed_scene_at == nil}
  end
  helper_method :all_recipients

  def send_message resource
    message = resource.build_outbound_message message: recruitment_message

    client = Incidents::SMSClient.new(incident.chapter)
    client.send_message(message)
  end

  def recruitment_message
    "DCSOps Incident Recruitment: #{parent.recruitment_message} - Reply with yes or no."
  end

  def build_resource_params
    attrs = params.fetch(:incidents_responder_recruitment, {}).permit(:person_id, :outbound_message)
    attrs[:person_id] ||= params[:person_id]
    #attrs[:incident_id] = incident.id
    [attrs]
  end

  def incident
    @real_incident ||= Incidents::IncidentPresenter.new(parent)
  end
  helper_method :incident

  def after_create_url
    incidents_chapter_incident_responders_path(parent, incident)
  end

end