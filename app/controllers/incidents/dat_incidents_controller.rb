class Incidents::DatIncidentsController < Incidents::BaseController
  inherit_resources
  respond_to :html, :json
  
  belongs_to :region, finder: :find_by_url_slug!, parent_class: Roster::Region
  belongs_to :incident, finder: :find_by_incident_number!, parent_class: Incidents::Incident
  
  defaults singleton: true, route_instance_name: :dat
  load_and_authorize_resource :region
  load_and_authorize_resource :dat_incident, class: Incidents::DatIncident
 

  actions :all, except: [:destroy]

  prepend_before_action :redirect_from_existing_incident, only: :new

  def redirect_from_existing_incident
    if parent.dat_incident and !parent.dat_incident.new_record?
      redirect_to action: :edit and return
    end
  end

  def new
    build_resource

    begin
      idat_db = current_region.idat_database
      if idat_db.present?
        importer = Idat::IncidentImporter.new(idat_db)
        importer.get_incident(params[:incident_id], resource)
      end
    rescue => e
      Raven.capture e
    end

    new!
  end

  def edit
    unless parent? and parent.dat_incident
      #redirect_to action: :new and return
      build_resource
    end
    if params[:status]
      resource.incident.status = params[:status]
      resource.valid?
    end
    build_partner_uses(resource.incident) # the valid? call wipes out uses sometimes
    if params[:panel_name]
      @rendering_panel = params[:panel_name]
      render action: 'panel', layout: nil
    else
      edit!
    end
  end

  def update
    action = params[:action] == 'create' ? :create! : :update!
    self.send(action) do |success, failure|
      success.html {notify(params[:action] == 'create'); redirect_to parent_path}
      success.js { notify(params[:action] == 'create'); render action: 'update' }
      failure.html { flash.now[:error] = "The incident report is incomplete.  Please correct the fields highlighted in red and try again."; render action: 'edit'}
      failure.js { render action: 'panel', layout: nil}
    end
  end
  alias_method :create, :update

  private
  def notify(is_new=true)
    if resource.incident.previous_changes.key? 'cas_event_number'
      Incidents::UpdateCasEventJob.enqueue resource.incident_id
    end
    if resource.incident.status == 'closed'
      Incidents::Notifications::Notification.create_for_event resource.incident, 'incident_report_filed', is_new: is_new
      Delayed::Job.enqueue Incidents::UpdateDrivingDistanceJob::ForIncident.new(resource.incident_id)
    end
    Incidents::UpdatePublisher.new(parent.region, parent).publish_details
  end

  helper_method :form_url
  def form_url
    resource_path
  end

  expose(:scheduler_service) { Scheduler::SchedulerService.new(@region) }

  def update_resource(obj, attrs)
    super(obj, attrs).tap {|success|
      if success && (resource.incident.previous_changes.keys & [:address, :city, :state, :zip, :county, :lat, :lng]).present?
        Incidents::ResponseTerritoryMatcher.new(obj.incident).perform
        obj.incident.save
      end
    }
  end


  def prepare_resource(obj)
    inc_attrs = incident_params
    obj.incident.attributes = inc_attrs if inc_attrs

    return unless %w(new edit).include? params[:action] 

    build_partner_uses obj.incident

    obj.incident.build_team_lead role: 'team_lead', response: 'available' unless obj.incident.team_lead
  end

  def build_partner_uses(inc)
    [:evac, :feeding, :hotel, :shelter].each do |type|
      unless inc.send("#{type}_partner_use")
        inc.send("build_#{type}_partner_use")
      end
    end
  end

  def build_resource
    return @resource if @resource

    obj = super

    obj.completed_by ||= current_user
    prepare_resource(obj)    

    @resource = obj
  end

  def resource
    @resource ||= super.tap{|obj| prepare_resource(obj) }
  end

  #def end_of_association_chain
  #  Incidents::Incident.includes(dat_incident: [:completed_by, :vehicles], responder_assignments: :person)
  #                     .for_region(current_chapter)
  #                     .where{(incident_number == my{params[:incident_id]})}
  #                     .first!
  #end

    # Never trust parameters from the scary internet, only allow the white list through.
    def resource_params
      return [] if request.get?

      keys = [:incident_call_type, :team_lead_id, :num_cases, 
             :incident_type, :reason_marked_invalid, :incident_description, :narrative_brief, :narrative,
             :num_people_injured, :num_people_hospitalized, :num_people_deceased, :num_people_missing,
             :responder_notified, :responder_arrived, :responder_departed,
             :units_affected, :units_minor, :units_major, :units_destroyed, :units_unknown,
             :structure_type, :num_first_responders,
             :suspicious_fire, :injuries_black, :injuries_red, :injuries_yellow,
             :where_started, :under_control_at, :box, :box_at, :battalion, :num_alarms,
             :size_up, :num_exposures, :vacate_type, :vacate_number, :hazardous_materials,
             {vehicle_ids: []},
             {languages: []},
             {services: []}
           ]

      keys = keys + Incidents::DatIncident::TRACKED_RESOURCE_TYPES.map(&:to_sym)

      args = params.require(:incidents_dat_incident).permit(*keys)
      if args[:vehicle_ids]
        args[:vehicle_ids] = Array(args[:vehicle_ids]).select(&:present?).uniq
      end

      [args]
    end

    def incident_params
      return nil if request.get?
      return @_incident_params if defined?(@_incident_params)

      partner_use_params = [:partner_id, :partner_name, :hotel_rate, :hotel_rooms, :meals_served]

      base = params.require(:incidents_dat_incident).fetch(:incident_attributes, {})
      @_incident_params ||= base.permit([
        :incident_type, :reason_marked_invalid, :response_territory_id, :narrative, :status, :cas_event_number,
        :address, :city, :state, :zip, :lat, :lng, :county, :neighborhood, :address_directly_entered,
        :num_adults, :num_children, :num_families,
        {:team_lead_attributes => [:id, :person_id, :role, :response]},
        {:responder_assignments_attributes => [:id, :person_id, :role, :response, :_destroy, :was_flex]},
        :evac_partner_used,
        {:evac_partner_use_attributes => partner_use_params},
        :feeding_partner_used,
        {:feeding_partner_use_attributes => partner_use_params},
        :shelter_partner_used,
        {:shelter_partner_use_attributes => partner_use_params},
        :hotel_partner_used,
        {:hotel_partner_use_attributes => partner_use_params},
        {:timeline_attributes => Incidents::TimelineProxy::EVENT_TYPES.map{|key| {"#{key}_attributes" => [:event_time, :source_id]}}}
      ])
    end

    def scope
      @scope ||= Incidents::Scope.for_region(parent.region_id)
    end
    helper_method :scope
end
