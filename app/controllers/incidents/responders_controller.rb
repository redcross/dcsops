class Incidents::RespondersController < Incidents::BaseController
  inherit_resources
  respond_to :html, :json
  belongs_to :incident, finder: :find_by_incident_number!, parent_class: Incidents::Incident
  defaults resource_class: Incidents::ResponderAssignment, collection_name: 'all_responder_assignments'
  custom_actions collection: [:available]
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

  protected

  def notify_assignment
    return unless resource.was_available

    if params[:send_assignment_email]
      Incidents::RespondersMailer.assign_email(resource).deliver
      flash[:notice] = 'Sent assignment email.'
    end
    if params[:send_assignment_sms] and resource.person.sms_addresses.present?
      Incidents::RespondersMailer.assign_sms(resource).deliver
      flash[:notice] = 'Sent assignment SMS.'
    end
  end

  def resource_params
    return [] if request.get?
    [params.require(:incidents_responder_assignment).permit(:person_id, :was_flex, :role, :send_assignment_sms, :send_assignment_email)]
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


  expose(:ignore_area) { current_chapter.incidents_dispatch_console_ignore_county || (params[:ignore_area] == '1') }
  expose(:scheduler_service) { Scheduler::SchedulerService.new(current_chapter) }

end
