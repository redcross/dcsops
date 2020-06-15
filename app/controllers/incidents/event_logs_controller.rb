class Incidents::EventLogsController < Incidents::EditPanelController
  self.panel_name = ['timeline', 'iir']
  belongs_to :region, finder: :find_by_url_slug!, parent_class: Roster::Region
  belongs_to :incident, finder: :find_by_incident_number!, parent_class: Incidents::Incident, optional: true
  #defaults route_prefix: nil
  before_action :require_parent_or_global_log
  include Searchable, RESTfulNotification
  responders :partial
  respond_to :html, :js


  has_scope :event_scope do |controller, scope, val|
    case val
    when 'global' then scope.where{incident_id == nil}
    when 'incident' then scope.where{incident_id != nil}
    else scope
    end
  end

  def index
    build_resource
    super
  end

  protected

  def notify resource
    Incidents::UpdatePublisher.new(@region, parent).publish_timeline
  end

  def create_resource resource
    super(resource).tap do |success|
      if success and resource.incident and resource.event == 'dispatch_relayed'
        Incidents::Notifications::Notification.create_for_event resource.incident, 'incident_dispatched', message: resource.message
      end
    end
  end

  def collection
    @collection ||= begin
      coll = super.includes(:incident, :person, incident: :region).order(event_time: :desc)
      coll = coll.page(params[:page]) if paginate?
      coll
    end
  end

  def build_resource
    super.tap{|log| log.event_time ||= Time.current }
  end

  def resource_params
    [params.fetch(:incidents_event_log, {}).permit(:event, :event_time, :message, :source_id).merge(person_id: current_user.id, region_id: region_id)]
  end

  def paginate?
    params[:page] != 'all'
  end

  def region_id
    @region.id
  end

  def smart_collection_url
    parent? ? parent_path : collection_path
  end

  def require_parent_or_global_log
    unless parent? || @region.incidents_use_global_log
      redirect_to parent_path
    end
  end

  public
  def valid_partial? name
    name == 'table'
  end

  def resource_path res=nil, *args
    res ||= resource
    if @incident
      incidents_region_incident_event_log_path(@region, @incident, res, *args)
    else
      incidents_region_event_log_path(@region, res, *args)
    end
  end

  def new_resource_path *args
    if @incident
      new_incidents_region_incident_event_log_path(@region, @incident, *args)
    else
      new_incidents_region_event_log_path(@region, *args)
    end
  end

  def collection_path *args
    if @incident
      incidents_region_incident_event_logs_path(@region, @incident, *args)
    else
      incidents_region_event_logs_path(@region, *args)
    end
  end

  def parent_path *args
    if @incident
      incidents_region_incident_path @region, @incident, *args
    else
      incidents_region_root_path @region, *args
    end
  end

  def original_url
    request.original_url
  end
  helper_method :original_url

end