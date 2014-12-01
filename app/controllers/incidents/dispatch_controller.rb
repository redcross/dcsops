class Incidents::DispatchController < Incidents::BaseController
  inherit_resources
  defaults resource_class: Incidents::Incident, finder: :find_by_incident_number!, collection_name: :incidents, route_instance_name: :dispatch, route_collection_name: :dispatch
  belongs_to :chapter, parent_class: Incidents::Scope, finder: :find_by_url_slug!
  load_and_authorize_resource :chapter
  load_and_authorize_resource class: "Incidents::Incident"

  actions :index, :update, :show
  custom_actions resource: [:next_contact, :complete]
  layout ->controller{ controller.request.xhr? ? false : nil }
  before_filter :ensure_has_dispatch_contact, only: [:show, :next_contact, :complete]

  def complete
    if resource.current_dispatch_contact_id != params[:contact_id].to_i

    end

    log_action params[:dispatch_note]
    resource.event_logs.create! event: 'dispatch_relayed', event_time: Time.current, message: "Relayed to #{person.full_name}"
    resource.responder_assignments.create! person: person, role: 'responder'
    dispatch_info = resource.event_logs.find_by event: 'dispatch_received'
    Incidents::Notifications::Notification.create_for_event resource, 'incident_dispatched', message: "Incident dispatched to #{person.full_name}.\n\nDetails:\n#{dispatch_info.try(:message)}"
    resource.update current_dispatch_contact_id: nil

    flash[:success] = "Incident #{resource.incident_number} has been dispatched."
    redirect_to collection_path
  end

  def next_contact
    log_action params[:dispatch_note]
    resource.responder_assignments.create! person: person, role: 'not_available'
    Incidents::DispatchService.new(resource).assign_contact

    flash[:success] = "Incident #{resource.incident_number} has been updated."
    redirect_to collection_path
  end

  protected

  def ensure_has_dispatch_contact
    unless person
      params[:error] = "That incident is not currently open for dispatch."
      redirect_to :back
    end
  end

  def person
    resource.current_dispatch_contact
  end

  def log_action(notes)
    person = resource.current_dispatch_contact
    resource.event_logs.create! event: 'dispatch_note', event_time: Time.current-1, person: current_user, message: "Call to #{person.try :full_name}:\n#{notes}"
  end

  def collection
    @coll ||= super.where{current_dispatch_contact_id != nil}
  end

  def publisher
    @publisher ||= Incidents::UpdatePublisher.new(resource.chapter, resource)
  end
end