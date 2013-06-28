class Incidents::DatIncidentsController < Incidents::BaseController
  inherit_resources
  belongs_to :incident, singleton: true, finder: :find_by_incident_number!, parent_class: Incidents::Incident

  actions :all, except: [:destroy]

  def new
    if parent? and parent.dat_incident and !parent.dat_incident.new_record?
      redirect_to action: :edit and return
    end

    super
  end

  def edit
    unless parent? and parent.dat_incident
      redirect_to action: :new and return
    end
    #resource.build_team_lead role: 'team_lead' unless resource.team_lead
    edit!
  end

  def create
    #build_resource.responder_assignments.build
    create! do |success, failure|
      success.html { Incidents::IncidentReportFiled.new(resource.incident.reload).save; redirect_to resource.incident}
    end
  end

  def update
    update! {url_for resource.incident }
  end

  private
  helper_method :form_url
  def form_url
    params[:incident_id] ? incidents_incident_dat_path(params[:incident_id]) : incidents_dat_incidents_path
  end

  helper_method :grouped_responder_roles
  def grouped_responder_roles
    [["Did Not Respond", Incidents::ResponderAssignment::RESPONSES_TO_LABELS.invert.to_a],
     ["Responded To Incident", Incidents::ResponderAssignment::ROLES_TO_LABELS.invert.to_a.reject{|a| a.last == 'team_lead'}]]
  end

  helper_method :scheduled_responders, :flex_responders
  def scheduled_responders(obj=@dat_incident)
    if obj.incident.county
      time = obj.incident.created_at || current_user.chapter.time_zone.now
      groups = Scheduler::ShiftGroup.current_groups_for_chapter(current_user.chapter, time)
      assignments = groups.map{|grp| Scheduler::ShiftAssignment.joins{shift}.where{(shift.county_id == my{obj.incident.county}) & (shift.shift_group_id == grp) & (date == grp.start_date)}}.flatten
                    .select{|ass| !obj.incident.responder_assignments.detect{|resp| resp.person == ass.person }}
    else
      []
    end
  end

  def flex_responders(obj=@dat_incident, scheduled_responders)
    if obj.incident.county
      time = obj.incident.created_at.in_time_zone(current_user.chapter.time_zone) || current_user.chapter.time_zone.now
      dow = time.strftime("%A").downcase
      hour = time.hour
      period = (hour >= 7 && hour < 19) ? 'day' : 'night'
      schedules = Scheduler::FlexSchedule.for_county(obj.incident.county).available_at(dow, period)
      assignments = schedules.select{|sched| !obj.incident.responder_assignments.detect{|resp| resp.person == sched.person }}
                    .select{|sched| !scheduled_responders.detect{|resp| resp.person == sched.person }}
    else
      []
    end
  end

  def build_resource
    return @_build_resource if @_build_resource

    obj = super

    obj.completed_by ||= current_user
    obj.build_incident if obj.incident.nil?
    obj.incident.attributes = incident_params if incident_params
    obj.incident.build_team_lead role: 'team_lead', response: 'available' unless obj.incident.team_lead

    #scheduled_responders(obj).each do |resp|
    #  obj.responder_assignments.build person: resp.person unless obj.responder_assignments.detect{|ra| ra.person == resp.person}
    #end

    @_build_resource = obj
  end

  def update_resource(object, attributes)
    object.build_incident if object.incident.nil?
    object.incident.attributes = incident_params if incident_params
    object.update_attributes(*attributes)
  end

    #def build_resource
    #  rec = super
    #  params = resource_params.first || {}
    #  if params[:incident_id].nil?
    #    rec.build_incident params[:incident_attributes]
    #  end
    #  if params[:responder_assignments_attributes]
    #    params[:responder_assignments_attributes].each do |data|
    #      rec.responder_assignments.build data
    #    end
    #  end
    #  rec.responder_assignments.build
    #  rec
    #end

    # Never trust parameters from the scary internet, only allow the white list through.
    def resource_params
      return [] if request.get?

      keys = [:incident_call_type, :team_lead_id,
             :date, :city, :address, :state, :cross_street, :zip, :lat, :lng, :neighborhood,
             :num_adults, :num_children, :num_families, :num_cases, 
             :incident_type, :incident_description, :narrative_brief, :narrative,
             :num_people_injured, :num_people_hospitalized, :num_people_deceased,
             :responder_notified, :responder_arrived, :responder_departed,
             :units_total, :units_affected, :units_minor, :units_major, :units_destroyed,
             :structure_type, :comfort_kits_used, :blankets_used,
             vehicle_ids: []
           ]

      keys += [
        {languages: []}
      ]

      keys << {:services => []}

      args = params.require(:incidents_dat_incident).permit(*keys)
      #if args[:incident_attributes]
      #  args[:incident_attributes][:chapter_id] = current_user.chapter_id
      #end

      [args]
    end

    def incident_params
      return nil if request.get?

      @_incident_params ||= params.require(:incidents_dat_incident).permit({:incident_attributes => [
        :team_lead_attributes => [:id, :person_id, :role, :response],
        :responder_assignments_attributes => [:id, :person_id, :role, :response, :_destroy, :was_flex]
      ]})[:incident_attributes]
    end
end
