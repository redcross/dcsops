class Incidents::RespondersController < Incidents::BaseController
  inherit_resources
  respond_to :html, :json, :js
  belongs_to :region, finder: :find_by_url_slug!, parent_class: Roster::Region do
    belongs_to :incident, finder: :find_by_incident_number!, parent_class: Incidents::Incident
  end
  defaults resource_class: Incidents::ResponderAssignment, collection_name: 'all_responder_assignments'
  custom_actions collection: [:available], resource: [:status]

  load_and_authorize_resource :region
  load_and_authorize_resource class: 'Incidents::ResponderAssignment'
  helper Incidents::MapHelper
  responders :partial

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
    case new_status
    when 'dispatched'
      resource.dispatched!
    when 'on_scene'
      resource.on_scene!
    when 'departed_scene'
      resource.departed_scene!
    end

    Incidents::UpdatePublisher.new(parent.region, parent).publish_responders
    respond_with resource, location: smart_resource_url do |fmt|
      fmt.js { render action: :update }
    end
  end

  def valid_partial? partial
    %w(assigned_table responders_table).include? partial
  end


  protected

  def notify_assignment
    Incidents::UpdatePublisher.new(parent.region, parent).publish_responders
    return unless resource.was_available

    send_assignment_email if params[:send_assignment_email]
    send_assignment_sms if params[:send_assignment_sms] and resource.person.sms_addresses.present?
  end

  def send_assignment_email
    Incidents::RespondersMailer.assign_email(resource).deliver
    flash[:notice] = 'Sent assignment email.'
  end

  def send_assignment_sms
    message = build_assignment_sms_message
    sms_client.send_message(message)
    flash[:notice] = 'Sent assignment SMS.'
  end

  def sms_client
    @sms_client ||= Incidents::SMSClient.new(parent.region)
  end

  def build_assignment_sms_message
    incident = Incidents::IncidentPresenter.new(parent)
    Incidents::ResponderMessage.new region: parent.region, incident: parent, person: resource.person, responder_assignment: resource,
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
    @collection ||= super.includes(:person)
  end

  def recruitments
    @recruitments ||= Incidents::ResponderRecruitment.for_incident(parent).group_by(&:person_id)
  end
  helper_method :recruitments

  def has_shift_notes
    @has_shift_notes ||= !Scheduler::ShiftAssignment.todays_shifts_with_notes(parent.region).empty?
  end
  helper_method :has_shift_notes

  expose(:ignore_shift_territory) { parent.region.incidents_dispatch_console_ignore_shift_territory || (params[:ignore_shift_territory] == '1') }
  expose(:dispatched) { parent.dispatched? }
  expose(:service) { 
    Incidents::RespondersService.new(parent, collection, ignore_shift_territory_scheduled: ignore_shift_territory, ignore_shift_territory_flex: ignore_shift_territory, ignore_dispatch: dispatched )
  }

  def scope
    @scope ||= Incidents::Scope.for_region(parent.region_id)
  end
  helper_method :scope

end
