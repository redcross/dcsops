class Incidents::RespondersController < Incidents::BaseController
  inherit_resources
  respond_to :html, :json, :js
  belongs_to :incident, finder: :find_by_incident_number!, parent_class: Incidents::Incident
  defaults resource_class: Incidents::ResponderAssignment, collection_name: 'all_responder_assignments'
  custom_actions collection: [:available], resource: [:status]
  load_and_authorize_resource class: 'Incidents::ResponderAssignment'
  helper Incidents::MapHelper

  actions :all, :except => :show

  def index
    unless parent.lat and parent.lng
      flash.now[:error] = 'No location specified for this incident.  Go to the incident report and add a location in order to see responder distance and map.'
    end
    index!
  end

  def update
    action = params[:action] == 'create' ? :create! : :update!
    self.send(action) do |success, failure|
      success.html { notify_assignment; redirect_to collection_path }
      success.js { notify_assignment; render action: 'update' }
      failure.js { render action: 'edit', layout: nil}
    end
  end
  alias_method :create, :update

  def update_status
    new_status = params[:status]
    if %w(dispatched on_scene departed_scene).include? new_status
      val = resource.send("#{new_status}_at")
      resource.send("#{new_status}_at=", val || current_chapter.time_zone.now)
      resource.save
    end
    if new_status == 'on_scene'
      resource.on_scene!
    elsif new_status == 'departed_scene'
      resource.departed_scene!
    end
    Incidents::ResponderMessageTablePublisher.new(parent).publish_responders
    respond_with resource, location: smart_resource_url do |fmt|
      fmt.js { render action: :update }
    end
  end

  def valid_partial? partial
    %w(assigned_table responders_table).include? partial
  end


  protected

  def notify_assignment
    Incidents::ResponderMessageTablePublisher.new(parent).publish_responders
    return unless resource.was_available

    if params[:send_assignment_email]
      Incidents::RespondersMailer.assign_email(resource).deliver
      flash[:notice] = 'Sent assignment email.'
    end
    if params[:send_assignment_sms] and resource.person.sms_addresses.present?
      message = build_assignment_sms_message
      sms_client.send_message(message)
      flash[:notice] = 'Sent assignment SMS.'
    end
  end

  def sms_client
    @sms_client ||= Incidents::SMSClient.new(parent.chapter)
  end

  def build_assignment_sms_message
    incident = Incidents::IncidentPresenter.new(parent)
    Incidents::ResponderMessage.new chapter: parent.chapter, incident: parent, person: resource.person, responder_assignment: resource,
                                    message: "You are assigned to #{incident.incident_number} as #{resource.humanized_role} at #{incident.address}, #{incident.city}. View location on map: #{view_context.short_url(incident.map_url)} Reply COMMANDS for help."
  end

  def resource_params
    return [] if request.get?
    [params.require(:incidents_responder_assignment).permit(:person_id, :was_flex, :role, :send_assignment_sms, :send_assignment_email, :driving_distance, :dispatched_at, :on_scene_at, :departed_scene_at)]
  end

  def build_resource
    @assignment ||= super.tap{|a| prepare_resource a }
  end

  def resource
    @assignment ||= super.tap{|a| prepare_resource a }
  end

  def create_resource(res)
    res.dispatched_at ||= current_chapter.time_zone.now if res.was_available
    super(res)
  end

  def prepare_resource(assignment)
    if params[:person_id]
      assignment.person_id ||= params[:person_id]
    end
    if params[:flex] == '1'
      assignment.was_flex = true
    end
  end

  helper_method :person
  def person
    @person ||= if params[:person_id]
      resource.person || Roster::Person.find(params[:person_id])
    else
      resource.person
    end
  end

  def collection
    @collection ||= super.includes{person}
  end

  def recruitments
    @recruitments ||= Incidents::ResponderRecruitment.for_incident(parent).group_by(&:person_id)
  end
  helper_method :recruitments

  expose(:ignore_area) { current_chapter.incidents_dispatch_console_ignore_county || (params[:ignore_area] == '1') }
  expose(:service) { Incidents::RespondersService.new(parent, collection, ignore_area_scheduled: ignore_area, ignore_area_flex: true) }
end
