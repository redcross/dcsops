class Incidents::InitialIncidentReportsController < Incidents::EditPanelController
  self.panel_name = 'iir'
  # Belongs to is reversed for singletons
  belongs_to :incident, finder: :find_by_incident_number!, parent_class: Incidents::Incident
  belongs_to :chapter, finder: :find_by_url_slug!, parent_class: Roster::Chapter
  defaults singleton: true
  include RESTfulNotification
  respond_to :html, :js
  custom_actions resource: [:approve, :really_approve, :unapprove]
  before_filter :check_unapproved, only: [:edit, :update]

  def index
    build_resource
    super
  end

  def edit
    resource || build_resource
    super
  end

  def approve
    resource.approved_by = current_user
    if resource.valid?
      render action: 'approve'
    else
      render action: 'approve_incomplete'
    end
  end

  def unapprove
    resource.update approved_by: nil
    flash[:success] = "The Initial Incident Report has been unapproved and can now be edited."
    render action: :update
  end

  def really_approve
    resource.update approved_by: current_user
    Incidents::PrepareIirJob.enqueue resource
    notify resource
    render action: :update
  end

  protected

  def check_unapproved
    if resource.approved_by_id
      render action: 'already_approved'
    end
  end

  def notify resource
    Incidents::UpdatePublisher.new(@chapter, parent).publish_iir
  end

  def resource_params
    [params.fetch(:incidents_initial_incident_report, {}).permit(:budget_exceeded, :trend, :estimated_units, :estimated_individuals, :significant_media, :safety_concerns, :weather_concerns, triggers: [], expected_services: []).merge(completed_by_id: current_user.id)]
  end

  def paginate?
    params[:page] != 'all'
  end

  def chapter_id
    @chapter.id
  end

  def after_create_url
    incidents_chapter_incident_path(@chapter, @incident, anchor: "inc-iir")
  end

  def resource_path *args
    incidents_chapter_incident_initial_incident_report_path(@chapter, @incident, *args)
  end

  public
  def valid_partial? name
    name == 'table'
  end

  def original_url
    request.original_url
  end
  helper_method :original_url

end