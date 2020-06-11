class Incidents::IncidentsController < Incidents::BaseController
  inherit_resources
  respond_to :html
  respond_to :json, only: :update
  respond_to :js, only: [:index, :needs_report]
  defaults finder: :find_by_incident_number!
  load_and_authorize_resource :region
  load_and_authorize_resource except: [:needs_report, :activity, :new, :create]
  belongs_to :region, parent_class: Roster::Region, finder: :find_by_url_slug!
  helper Incidents::MapHelper
  responders :partial

  actions :all, except: :index
  custom_actions collection: [:needs_report, :activity, :map], resource: [:mark_invalid, :close, :force_close, :reopen]

  include HasManyRoutesFor
  has_many_routes_for :responder_messages, :dat, :event_logs, :responders, :attachments, :notifications, :cases, :initial_incident_report

  def create
    create! { after_create_path }
    if resource.errors.blank?
      Incidents::Notifications::Notification.create_for_event resource, 'new_incident'
      publisher.publish_details
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
      publisher.publish_details
      Incidents::Notifications::Notification.create_for_event resource, 'incident_report_filed'
      Delayed::Job.enqueue Incidents::UpdateDrivingDistanceJob::ForIncident.new(resource.id)
    else
      redirect_to edit_resource_dat_path(status: 'closed')
    end
  end

  def force_close
    resource.force_close!
    redirect_to resource_path
  end

  def reopen
    resource.update_attribute :status, 'open'
    resource.update_attribute :last_no_incident_warning, 1.hour.ago
    redirect_to resource_path

    publisher.publish_details
  end

  def activity
    association_chain # To load the @region variable
    authorize! :read_case_details, resource_class
  end

  before_action :require_open_incident, only: :mark_invalid
  def mark_invalid
    if params[:incidents_incident] and resource.update_attributes mark_invalid_params
      flash[:info] = 'The incident has been removed.'
      Incidents::Notifications::Notification.create_for_event resource, 'incident_invalid'
      redirect_to needs_report_resources_path
    end
  end

  def valid_partial? partial
    tab_authorized? partial
  end

  private
  def after_create_path
    Incidents::IncidentPresenter.new(resource).submit_path
  end

  def mark_invalid_params
    params.require(:incidents_incident).permit(:reason_marked_invalid, :narrative).merge(status: 'invalid')
  end

  def require_open_incident    
    unless resource.open_incident?
      flash[:error] = 'This incident has already been completed.'
      redirect_to needs_report_resources_path
    end
  end

    helper_method :inline_editable?
    def inline_editable?
      region = resource.region
      region && region.incidents_report_editable && resource.open_incident? && can?(:update, resource.dat_incident || Incidents::DatIncident.new(incident: resource))
    end

    helper_method :tab_authorized?
    def tab_authorized?(name)
      case name
      when 'summary','response_territory' then true
      when 'details', 'timeline', 'responders', 'attachments' then can? :read_details, resource
      when 'cases' then resource.region.incidents_collect_case_details && can?(:read_case_details, resource)
      when 'changes' then can? :read_changes, resource
      when 'iir' then can?(:read, Incidents::InitialIncidentReport) && (resource.status=='open' || resource.initial_incident_report.present?)
      else false
      end
    end

    expose(:needs_report_collection) { 
      @needs_report_collection_with_pagination ||= begin
        collection = Incidents::Incident.for_region(delegated_region_ids).needs_incident_report.includes{shift_territory}.order{incident_number}
        collection.page(params[:page])
      end
    }

    def original_url
      request.original_url
    end
    helper_method :original_url

    expose(:resource_changes) {
      changes = Version.order{created_at.desc}.for_region(@region).includes{[root, item]}
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

    def build_resource
      @resource ||= super.tap{|i| 
        i.date ||= Date.current
        unless i.response_territory
          Incidents::ResponseTerritoryMatcher.new(i, Incidents::ResponseTerritory.all).perform
        end
        i.region = i.response_territory.try :region if i.response_territory
      }
    end

    def create_resource obj
      if can? :create, obj
        super obj
      else
        obj.errors[:base] = "You cannot create incidents for this region."
        false
      end
    end

    def resource
      @resource_presenter ||= Incidents::IncidentPresenter.new(super)
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def resource_params
      keys = [:response_territory_id, :date, :incident_type, :reason_marked_invalid, :status, :narrative, :address, :city, :state, :zip, :neighborhood, :county, :lat, :lng, :address_directly_entered, :recruitment_message]

      keys << :incident_number if params[:action] == 'create' && !has_incident_number_sequence?

      attrs = params.fetch(:incidents_incident, {}).permit(*keys)
      attrs.merge!({status: 'open'})

      [attrs]
    end

    def delegated_region_ids
      @delgated_regions ||= [@region.id] + Roster::Region.with_incidents_delegate_region_value(@region.id).ids
    end

    def shift_territories_for_create
      Roster::ShiftTerritory.where{region_id.in my{delegated_region_ids}}
    end
    helper_method :shift_territories_for_create

    def publisher
      @publisher ||= Incidents::UpdatePublisher.new(resource.region, resource)
    end

    def scope
      @scope ||= Incidents::Scope.for_region(resource.region_id)
    end
    helper_method :scope

    def has_incident_number_sequence?
      parent.incident_number_sequence.present?
    end
    helper_method :has_incident_number_sequence?

end
