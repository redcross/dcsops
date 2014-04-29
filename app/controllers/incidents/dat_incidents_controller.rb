class Incidents::DatIncidentsController < Incidents::BaseController
  inherit_resources
  respond_to :html, :json
  #load_and_authorize_resource :incident, find_by: :find_by_incident_number!
  load_and_authorize_resource :dat_incident, class: Incidents::DatIncident
  defaults singleton: true
  belongs_to :incident, finder: :find_by_incident_number!, parent_class: Incidents::Incident

  actions :all, except: [:destroy]

  prepend_before_filter :redirect_from_existing_incident, only: :new

  def redirect_from_existing_incident
    if parent.dat_incident and !parent.dat_incident.new_record?
      redirect_to action: :edit and return
    end
  end

  def new
    build_resource

    begin
      idat_db = current_chapter.idat_database
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
    if params[:panel_name]
      render action: 'panel', layout: nil
    else
      edit!
    end
  end

  def update
    action = params[:action] == 'create' ? :create! : :update!
    self.send(action) do |success, failure|
      success.html {notify(params[:action] == 'create'); redirect_to resource.incident}
      success.js { notify(params[:action] == 'create'); render action: 'update' }
      failure.html { flash.now[:error] = "The incident report is incomplete.  Please correct the fields highlighted in red and try again."; render action: 'edit'}
      failure.js { render action: 'panel', layout: nil}
    end
  end
  alias_method :create, :update

  private
  def notify(is_new=true)
    Incidents::IncidentReportFiled.new(resource.incident.reload, is_new).save
  end

  helper_method :form_url
  def form_url
    params[:incident_id] ? incidents_incident_dat_path(params[:incident_id]) : incidents_dat_incidents_path
  end

  expose(:scheduler_service) { Scheduler::SchedulerService.new(current_chapter) }

  def prepare_resource(obj)
    inc_attrs = incident_params
    obj.incident.attributes = inc_attrs if inc_attrs

    return unless %w(new edit).include? params[:action] 

    obj.build_incident if obj.incident.nil?
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
    return @dat_incident if @dat_incident

    obj = super

    obj.completed_by ||= current_user
    prepare_resource(obj)    

    @dat_incident = obj
  end

  def resource
    @dat_incident ||= super.tap{|obj| prepare_resource(obj) }
  end

  def end_of_association_chain
    Incidents::Incident.includes{[dat_incident.completed_by, dat_incident.vehicles, responder_assignments.person]}
                       .for_chapter(current_chapter)
                       .where{(incident_number == my{params[:incident_id]})}
                       .first!
  end

    # Never trust parameters from the scary internet, only allow the white list through.
    def resource_params
      return [] if request.get?

      keys = [:incident_call_type, :team_lead_id, :num_cases, 
             :incident_type, :incident_description, :narrative_brief, :narrative,
             :num_people_injured, :num_people_hospitalized, :num_people_deceased,
             :responder_notified, :responder_arrived, :responder_departed,
             :units_affected, :units_minor, :units_major, :units_destroyed,
             :structure_type,
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

      base = params.require(:incidents_dat_incident)[:incident_attributes]
      if base
        @_incident_params ||= base.permit([
          :incident_type, :narrative, :status, :cas_incident_number,
          :address, :city, :state, :zip, :lat, :lng, :county, :neighborhood,
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
      else
        {}
      end
    end
end
