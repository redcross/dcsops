class Incidents::IncidentsController < Incidents::BaseController
  inherit_resources
  respond_to :html, :kml
  defaults finder: :find_by_incident_number!
  load_and_authorize_resource except: [:needs_report, :activity]
  helper Incidents::MapHelper

  include NamedQuerySupport

  custom_actions collection: [:needs_report, :tracker, :activity], resource: [:mark_invalid, :close, :reopen]

  has_scope :in_area, as: :area_id_eq

  def show
    if inline_editable? and resource.dat_incident.nil?
      resource.build_dat_incident
    end
    if partial = requested_partial_name
      render partial: partial
    else
      show!
    end
  end

  def create
    create! { current_chapter.incidents_report_editable ? resource_path(resource) : new_incidents_incident_dat_path(resource) }
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

  def activity
    authorize! :read_case_details, resource_class
  end

  before_filter :require_open_incident, only: :mark_invalid
  def mark_invalid
    if params[:incidents_incident] and resource.update_attributes mark_invalid_params
      flash[:info] = 'The incident has been removed.'
      Incidents::IncidentInvalid.new(resource).save
      redirect_to needs_report_resources_path
    end
  end

  private
  def mark_invalid_params
    params.require(:incidents_incident).permit(:incident_type, :narrative).merge(status: 'invalid')
  end

  def requested_partial_name
    partial = params[:partial] 
    if partial and tab_authorized?(partial)
      partial
    else
      nil
    end
  end

  def require_open_incident    
    unless resource.open_incident?
      flash[:error] = 'This incident has already been completed.'
      redirect_to needs_report_resources_path
    end
  end

    helper_method :inline_editable?
    def inline_editable?
      chapter = resource.chapter
      chapter && chapter.incidents_report_editable && resource.open_incident? && can?(:update, resource.dat_incident || Incidents::DatIncident.new(incident: resource))
    end

    helper_method :tab_authorized?
    def tab_authorized?(name)
      case name
      when 'summary', 'dispatch' then true
      when 'details', 'timeline', 'responders', 'attachments' then can? :read_details, resource
      when 'cases' then can? :read_case_details, resource
      when 'changes' then can? :read_case_details, resource
      else false
      end
    end

    def collection
      @_incidents ||= begin
        scope = apply_scopes(super).merge(search.result).order{[date.desc, incident_number.desc]}.includes{[area, dat_incident, team_lead.person]}
        scope = scope.page(params[:page]) if should_paginate
        scope
      end
    end

    expose(:needs_report_collection) { end_of_association_chain.needs_incident_report.includes{area}.order{incident_number} }
    expose(:tracker_collection) { apply_scopes(end_of_association_chain).open_cases.includes{cas_incident.cases}.uniq }

    expose(:resource_changes) {
      changes = PaperTrail::Version.scoped.order{created_at.desc}.for_chapter(current_chapter).includes{[root, item]}
      if params[:id] # we have a single resource
        changes = changes.for_root(resource)
      else
        changes = changes.for_type(resource_class.to_s).limit(50)
      end
      changes.to_a
    }
    expose(:resource_change_people) {
      ids = resource_changes.map(&:whodunnit).select(&:present?).uniq
      people = Hash[Roster::Person.where{id.in(ids)}.map{|p| [p.id, p]}]
    }
    expose(:show_version_root) { params[:action] == 'activity' }

    expose(:search) { search_params = {status_in: ['open', 'closed']}.merge(params[:q] || {}); resource_class.search(search_params) }
    expose(:should_paginate) { params[:page] != 'all' }

    def end_of_association_chain
      named_query ? super : super.where{chapter_id == my{current_chapter}}
    end

    def build_resource
      super.tap{|i| i.date ||= Date.current}
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def resource_params
      return [] if request.get?

      keys = [:area_id, :date, :incident_type, :status]

      keys << :incident_number if params[:action] == 'create'

      attrs = params.require(:incidents_incident).permit(*keys)
      attrs.merge!({chapter_id: current_chapter.id, status: 'open'})

      [attrs]
    end
end
