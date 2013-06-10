class Incidents::DatIncidentsController < Incidents::BaseController
  inherit_resources
  belongs_to :incident, singleton: true, finder: :find_by_incident_number!, parent_class: Incidents::Incident, optional: true

  actions :all, except: [:destroy]

  def new
    build_resource.build_incident if build_resource.incident.nil?
    build_resource.responder_assignments.build
    build_resource.build_team_lead role: 'team_lead'

    if parent? and !parent.dat_incident
      redirect_to action: :show and return
    end
    super
  end

  def edit
    resource.build_team_lead role: 'team_lead' unless resource.team_lead
    edit!
  end

  def create
    #build_resource.responder_assignments.build
    create! { url_for resource.incident }
  end

  def update
    update! {url_for resource.incident }
  end

  private
  helper_method :form_url
  def form_url
    params[:incident_id] ? incidents_incident_dat_path(params[:incident_id]) : incidents_dat_incidents_path
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
             :units_total, :units_affected, :units_minor, :units_major, :units_destroyed 
           ]

      keys << {:incident_attributes => [:incident_number, :date, :county_id]}
      keys << {:team_lead_attributes => [:id, :person_id, :role, :response]}
      keys << {:responder_assignments_attributes => [:id, :person_id, :role, :response, :_destroy]}
      keys << {:services => []}

      args = params.require(:incidents_dat_incident).permit(*keys)
      if args[:incident_attributes]
        args[:incident_attributes][:chapter_id] = current_user.chapter_id
      end

      [args]
    end
end
