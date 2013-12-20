class Incidents::IncidentsController < Incidents::BaseController
  inherit_resources
  respond_to :html, :kml
  defaults finder: :find_by_incident_number!
  load_and_authorize_resource except: [:link_cas, :needs_report]
  helper Incidents::MapHelper

  include NamedQuerySupport

  custom_actions collection: [:needs_report, :link_cas, :tracker], resource: [:mark_invalid, :close, :reopen]

  has_scope :in_area, as: :area_id_eq

  def show
    if inline_editable? and resource.dat_incident.nil?
      resource.build_dat_incident
    end
    if partial = params[:partial] and tab_authorized?(partial)
      render partial: partial
    else
      show!
    end
  end

  def create
    create! { current_chapter.incidents_report_editable ? resource_path(resource) : new_incidents_incident_dat_path(resource) }
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
    unless resource.open_incident?
      flash[:error] = 'This incident has already been completed.'
      redirect_to needs_report_incidents_incidents_path
      return
    end

    if params[:incidents_incident]
      resource.attributes = (params.require(:incidents_incident).permit(:incident_type, :narrative)).merge(status: 'invalid')
      if resource.save
        flash[:info] = 'The incident has been removed.'
        Incidents::IncidentInvalid.new(resource).save
        redirect_to needs_report_incidents_incidents_path
      end
    end
  end

  def close
    dat = resource.dat_incident || resource.build_dat_incident
    dat.incident.status = 'closed'
    if dat.save
      redirect_to resource
    else
      redirect_to edit_incidents_incident_dat_path(resource, status: 'closed')
    end
  end

  def reopen
    resource.update_attributes status: 'open', last_no_incident_warning: 1.hour.ago
    redirect_to resource
  end

  private

    helper_method :inline_editable?
    def inline_editable?
      chapter = resource.chapter
      chapter && chapter.incidents_report_editable && resource.open_incident? && can?(:update, resource.dat_incident || Incidents::DatIncident.new(incident: resource))
    end

    helper_method :tab_authorized?
    def tab_authorized?(name)
      case name
      when 'summary', 'dispatch' then true
      when 'details', 'timeline', 'responders', 'photos' then can? :read_details, resource
      when 'cases' then can? :read_case_details, resource
      when 'changes' then can? :read_case_details, resource
      else false
      end
    end

    def collection
      @_incidents ||= begin
        scope = apply_scopes(super).merge(search.result).valid.order{date.desc}.includes{[area, dat_incident, team_lead.person]}
        scope = scope.page(params[:page]) if should_paginate
        scope
      end
    end

    expose(:needs_report_collection) { end_of_association_chain.needs_incident_report.includes{area}.order{incident_number} }
    expose(:tracker_collection) { apply_scopes(end_of_association_chain).open_cases.includes{cas_incident.cases}.uniq }
    expose(:cas_incidents_to_link) { Incidents::CasIncident.to_link_for_chapter(current_chapter) }
    expose(:county_names) { current_chapter.counties.map(&:name) }
    expose(:resource_changes) {
      changes = resource.versions
      changes += resource.dat_incident.versions if resource.dat_incident 
      changes.sort_by!(&:created_at).reverse!
    }
    expose(:resource_change_people) {
      ids = resource_changes.map(&:whodunnit).select(&:present?).uniq
      people = Hash[Roster::Person.where{id.in(ids)}.map{|p| [p.id, p]}]
    }

    expose(:search) { resource_class.search(params[:q]) }
    expose(:should_paginate) { params[:page] != 'all' }

    helper_method :incidents_for_cas
    def incidents_for_cas(cas)
      scope = Incidents::Incident.joins{cas_incident.outer}.where{(cas_incident.id == nil) & date.in((cas.incident_date - 7)..(cas.incident_date + 7))}
      if county_names.include? cas.county_name
        scope = scope.joins{area}.where{area.name == cas.county_name}
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
      keys = [:area_id, :date, :incident_type, :status]

      keys << :incident_number if params[:action] == 'create'


      request.get? ? [] : [params.require(:incidents_incident).permit(*keys).merge!({chapter_id: current_chapter.id})]
    end
end
