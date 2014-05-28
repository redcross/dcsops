class Incidents::CasLinkController < Incidents::BaseController
  inherit_resources
  belongs_to :chapter, parent_class: Roster::Chapter, finder: :find_by_url_slug!, collection_name: :cas_incidents
  defaults resource_class: Incidents::CasIncident, finder: :find_by_cas_incident_number!, collection_name: :cas_incidents
  actions only: [:index]
  custom_actions resource: [:link, :promote, :ignore]
  load_and_authorize_resource class: 'Incidents::CasIncident'

  before_filter :check_not_linked, only: [:link, :promote]

  def index
  end

  def link
    authorize! :link_cas, incident

    incident.link_to_cas_incident resource
    flash[:info] = 'Incident Linked'
    redirect_to collection_path
  end

  def promote
    resource.create_incident_from_cas! chapter
    flash[:info] = 'Incident Promoted'
    redirect_to collection_path
  end

  def ignore
    resource.update_attributes ignore_incident: true
    flash[:info] = 'Incident Ignored'
    redirect_to collection_path
  end

  private

  def check_not_linked
    if resource.incident
      flash[:error] = 'That CAS Incident is already linked.'
      redirect_to collection_path
    end
  end
  helper_method :collection
  def collection 
    @collection ||= super.to_link_for_chapter(chapter)
  end

  def incident
    @incident ||= Incidents::Incident.find params[:incident_id]
  end

  expose(:county_names) { chapter.counties.map(&:name) }

  def link_date_window(date)
    (date - 7)..(date + 7)
  end

  helper_method :incidents_for_cas
  def incidents_for_cas(cas)
    scope = Incidents::Incident.for_chapter(chapter)
                               .without_cas
                               .with_date_in(link_date_window(cas.incident_date))
                               .valid.order{date.desc}
    if cas.county_name
      scope = scope.with_county_name(cas.county_name)
    end
    scope.to_a
  end

  def chapter
    association_chain
    @chapter
  end

end