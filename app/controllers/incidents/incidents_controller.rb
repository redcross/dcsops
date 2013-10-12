class Incidents::IncidentsController < Incidents::BaseController
  inherit_resources
  respond_to :html, :kml
  defaults finder: :find_by_incident_number!
  load_and_authorize_resource except: [:link_cas, :needs_report]
  helper Incidents::MapHelper

  include NamedQuerySupport

  custom_actions collection: [:needs_report, :link_cas, :tracker], resource: :mark_invalid

  has_scope :in_area, as: :area_id_eq

  def create
    create! { new_incidents_incident_dat_path(resource) }
  end

  def link_cas
    authorize! :read, Incidents::CasIncident
    if request.post? and params[:cas_id] and params[:incident_id]
      cas = Incidents::CasIncident.find params[:cas_id]
      incident = Incidents::Incident.find params[:incident_id]

      authorize! :link, cas

      incident.link_to_cas_incident(cas)
    elsif request.post? and params[:cas_id] and params[:commit] == 'Promote to Incident'
      cas = Incidents::CasIncident.find params[:cas_id]

      authorize! :promote, cas
      cas.create_incident_from_cas!
    end
  end

  def mark_invalid
    resource.update_attributes(params.require(:incidents_incident).permit(:incident_type))
    if resource.save
      flash[:info] = 'The incident has been removed.'
      Incidents::IncidentInvalid.new(resource).save
    else
      flash[:error] = 'There was an error removing the incident.'
    end
    redirect_to needs_report_incidents_incidents_path
  end

  private

    def collection
      @_incidents ||= begin
        scope = apply_scopes(super).merge(search.result).valid.order{date.desc}.includes{[area, dat_incident, team_lead.person]}
        scope = scope.page(params[:page]) if should_paginate
        scope
      end
    end

    expose(:needs_report_collection) { end_of_association_chain.needs_incident_report.order{incident_number} }
    expose(:tracker_collection) { apply_scopes(end_of_association_chain).open_cases.includes{cas_incident.cases}.uniq }
    expose(:cas_incidents_to_link) { Incidents::CasIncident.where{incident_id == nil}.order{incident_date.desc} }
    expose(:county_names) { current_chapter.counties.map(&:name) }
    expose(:resource_changes) {
      changes = resource.versions
      changes += resource.dat_incident.versions if resource.dat_incident 
      changes.sort_by!(&:created_at).reverse!
    }

    expose(:search) { resource_class.search(params[:q]) }
    expose(:should_paginate) { params[:page] != 'all' }

    helper_method :incidents_for_cas
    def incidents_for_cas(cas)
      scope = Incidents::Incident.joins{cas_incident.outer}.where{(cas_incident.id == nil) & date.in((cas.incident_date - 7)..(cas.incident_date + 7))}
      if county_names.include? cas.county_name
        scope = scope.joins{county}.where{county.name == cas.county_name}
      end
      scope
    end

    def end_of_association_chain
      named_query ? super : super.where{chapter_id == my{current_chapter}}
    end

    def build_resource
      super.tap{|i| i.date ||= Date.current}
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def resource_params
      keys = [:area_id, :cas_incident_number, :incident_call_type, :team_lead_id,
             :date, :city, :address, :state, :cross_street, :zip, :lat, :lng,
             :units_affected, :num_adults, :num_children, :num_families, :num_cases, 
             :incident_type, :incident_description, :narrative_brief, :narrative]

      keys << :incident_number if params[:action] == 'create'


      request.get? ? [] : [params.require(:incidents_incident).permit(*keys).merge!({chapter_id: current_chapter.id})]
    end
end
