class Incidents::EventLogsController < Incidents::EditPanelController
  self.panel_name = ['timeline', 'iir']
  belongs_to :chapter, finder: :find_by_url_slug!, parent_class: Roster::Chapter
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
    Incidents::UpdatePublisher.new(@chapter, parent).publish_timeline
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
      coll = super.includes{[incident, person, incident.chapter]}.order(event_time :desc)
      coll = coll.page(params[:page]) if paginate?
      coll
    end
  end

  def build_resource
    super.tap{|log| log.event_time ||= Time.current }
  end

  def resource_params
    [params.fetch(:incidents_event_log, {}).permit(:event, :event_time, :message, :source_id).merge(person_id: current_user.id, chapter_id: chapter_id)]
  end

  def paginate?
    params[:page] != 'all'
  end

  def chapter_id
    @chapter.id
  end

  def smart_collection_url
    parent? ? parent_path : collection_path
  end

  def require_parent_or_global_log
    unless parent? || @chapter.incidents_use_global_log
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
      incidents_chapter_incident_event_log_path(@chapter, @incident, res, *args)
    else
      incidents_chapter_event_log_path(@chapter, res, *args)
    end
  end

  def new_resource_path *args
    if @incident
      new_incidents_chapter_incident_event_log_path(@chapter, @incident, *args)
    else
      new_incidents_chapter_event_log_path(@chapter, *args)
    end
  end

  def collection_path *args
    if @incident
      incidents_chapter_incident_event_logs_path(@chapter, @incident, *args)
    else
      incidents_chapter_event_logs_path(@chapter, *args)
    end
  end

  def parent_path *args
    if @incident
      incidents_chapter_incident_path @chapter, @incident, *args
    else
      incidents_chapter_root_path @chapter, *args
    end
  end

  def original_url
    request.original_url
  end
  helper_method :original_url

end