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

  def new
    if request.xhr?
      render layout: nil
    else
      super
    end
  end

  def update
    action = params[:action] == 'create' ? :create! : :update!
    self.send(action) do |success, failure|
      success.js { render action: 'update' }
      failure.js { render action: 'edit', layout: nil}
    end
  end
  alias_method :create, :update

  protected

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
    puts 'preparing'
    if params[:person_id]
      assignment.person_id = params[:person_id]
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

  helper_method :scheduled_responders, :flex_responders
  def scheduled_responders(obj=resource)
    if obj.area
      time = obj.created_at || current_chapter.time_zone.now
      groups = Scheduler::ShiftGroup.current_groups_for_chapter(current_chapter, time)
      assignments = Scheduler::ShiftAssignment.joins{[shift]}.includes{[shift, person]}.where{(shift.county_id == my{obj.area})}.for_active_groups(groups)
                    .where{person_id.not_in(my{collection.map(&:person_id)})}
    else
      []
    end
  end

  def flex_responders(obj=resource, scheduled_responders)
    if obj.area
      time = obj.created_at.in_time_zone(current_chapter.time_zone) || current_chapter.time_zone.now
      dow = time.strftime("%A").downcase
      hour = time.hour
      period = (hour >= 7 && hour < 19) ? 'day' : 'night'
      schedules = Scheduler::FlexSchedule.for_county(obj.area).available_at(dow, period).includes{person}
      assignments = schedules.where{person.id.not_in(my{collection.map(&:person_id)})}
                    .select{|sched| !scheduled_responders.detect{|resp| resp.person == sched.person }}
    else
      []
    end
  end
end
