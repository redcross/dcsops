class Incidents::IncidentsController < Incidents::BaseController
  inherit_resources
  respond_to :html
  respond_to :json, only: :update
  respond_to :js, only: :index
  defaults finder: :find_by_incident_number!
  load_and_authorize_resource :chapter
  load_and_authorize_resource except: [:needs_report, :activity]
  belongs_to :chapter, parent_class: Roster::Chapter, finder: :find_by_url_slug!
  helper Incidents::MapHelper
  responders :partial

  include Searchable

  def self.has_many *names
    names = names.flatten
    names.each do |name|
      name = name.to_s
      generate_url_and_path_helpers(nil, :"resource_#{name}", [:incidents, :chapter, :incident, name], ['@chapter', '@incident'])
      helper_method :"resource_#{name}_path"

      name = name.singularize
      actions = [nil, :edit, :new]
      actions.each do |action|
        if action == :new
          ivars = ['@chapter', '(given_args.first || @incident)']
        else
          ivars = ['@chapter', '@incident', 'nil']
        end
        generate_url_and_path_helpers(action, :"resource_#{name}", [:incidents, :chapter, :incident, name], ivars)
        helper_method :"#{action ? "#{action}_" : ''}resource_#{name}_path"
      end
    end
  end
  has_many :responder_messages, :dat, :event_logs, :responders, :attachments, :notifications

  custom_actions collection: [:needs_report, :activity, :map], resource: [:mark_invalid, :close, :reopen]

  has_scope :in_area, as: :area_id_eq
  has_scope :county_state_eq do |controller, scope, val|
    county_name, state_name = val.split ", "
    scope.where{(lower(county) == county_name.downcase) & (state == state_name)}
  end

  def create
    create! { after_create_path }
    if resource.errors.blank?
      Incidents::Notifications::Notification.create_for_event resource, 'new_incident'
    end
  end

  def show
    if inline_editable? and resource.dat_incident.nil?
      resource.build_dat_incident
    end
    show!
  end

  def close
    if resource.close!
      redirect_to resource_path
    else
      redirect_to edit_resource_dat_path(status: 'closed')
    end
  end

  def reopen
    resource.update_attribute :status, 'open'
    resource.update_attribute :last_no_incident_warning, 1.hour.ago
    redirect_to resource_path
  end

  def activity
    association_chain # To load the @chapter variable
    authorize! :read_case_details, resource_class
  end

  before_filter :require_open_incident, only: :mark_invalid
  def mark_invalid
    if params[:incidents_incident] and resource.update_attributes mark_invalid_params
      flash[:info] = 'The incident has been removed.'
      Incidents::Notifications::Notification.create_for_event resource, 'incident_invalid'
      redirect_to needs_report_resources_path
    end
  end

  def map
    params[:q] = {
      date_gteq: '2012-07-01',
      lat_not_null: true,
      lng_not_null: true
    }.merge(params[:q] || {})
    params[:page] = 'all'
  end

  def valid_partial? partial
    tab_authorized? partial
  end

  private
  def after_create_path
    Incidents::IncidentPresenter.new(resource).submit_path
  end

  def mark_invalid_params
    params.require(:incidents_incident).permit(:incident_type, :narrative).merge(status: 'invalid')
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
      when 'summary' then true
      when 'details', 'timeline', 'responders', 'attachments' then can? :read_details, resource
      when 'cases' then resource.chapter.incidents_collect_case_details && can?(:read_case_details, resource)
      when 'changes' then can? :read_changes, resource
      else false
      end
    end

    def collection
      @_incidents ||= begin
        scope = apply_scopes(super).order{[date.desc, incident_number.desc]}#.preload{[area, dat_incident, team_lead.person]}
        scope = scope.page(params[:page]) if should_paginate
        scope
      end
    end

    def collection_for_stats
      @stats_collection ||= collection.unscope(:limit, :offset, :order, :includes, :joins)
    end
    helper_method :collection_for_stats

    expose(:needs_report_collection) { 
      Incidents::Incident.for_chapter(delegated_chapter_ids).needs_incident_report.includes{area}.order{incident_number} 
    }

    expose(:resource_changes) {
      changes = PaperTrail::Version.order{created_at.desc}.for_chapter(@chapter).includes{[root, item]}
      if params[:id] # we have a single resource
        changes = changes.for_root(resource.__getobj__)
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

    def default_search_params
      {status_in: ['open', 'closed'], date_gteq: FiscalYear.current.start_date}
    end

    def should_paginate; params[:page] != 'all'; end

    def end_of_association_chain
      super#.where{chapter_id == my{current_chapter}}
    end

    def build_resource
      super.tap{|i| 
        i.date ||= Date.current
        i.chapter = i.area.chapter if i.area
      }
    end

    def resource
      @resource_presenter ||= Incidents::IncidentPresenter.new(super)
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def resource_params
      return [] if request.get?

      keys = [:area_id, :date, :incident_type, :status, :narrative, :address, :city, :state, :zip, :neighborhood, :county, :lat, :lng, :recruitment_message]

      keys << :incident_number if params[:action] == 'create' && !parent.incidents_sequence_enabled

      attrs = params.require(:incidents_incident).permit(*keys)
      attrs.merge!({status: 'open'})

      [attrs]
    end

    def original_url
      request.original_url
    end
    helper_method :original_url

    def delegated_chapter_ids
      @delgated_chapters ||= [@chapter.id] + Roster::Chapter.with_incidents_delegate_chapter_value(@chapter.id).ids
    end

    def counties_for_create
      Roster::County.where{chapter_id.in my{delegated_chapter_ids}}
    end
    helper_method :counties_for_create

end
