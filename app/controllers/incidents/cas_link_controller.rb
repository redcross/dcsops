class Incidents::CasLinkController < Incidents::BaseController
  inherit_resources
  defaults resource_class: Incidents::CasIncident, finder: :find_by_cas_incident_number!
  actions only: [:index]
  custom_actions resource: [:link, :promote]

  before_filter :check_not_linked, only: [:link, :promote]

  def index
    authorize! :read, Incidents::CasIncident
  end

  def link
    authorize! :link, resource
    authorize! :link_cas, incident

    incident.link_to_cas_incident resource
    flash[:info] = 'Incident Linked'
    redirect_to collection_path
  end

  def promote
    authorize! :promote, resource
    resource.create_incident_from_cas!
    flash[:info] = 'Incident Promoted'
    redirect_to collection_path
  end

  private

  def check_not_linked
    if resource.incident
      flash[:error] = 'That CAS Incident is already linked.'
      redirect_to collection_path
    end
  end

  def end_of_association_chain
    super.for_chapter(current_chapter)
  end

  helper_method :collection
  def collection 
    @collection ||= super.to_link_for_chapter(current_chapter)
  end

  def incident
    @incident ||= Incidents::Incident.find params[:incident_id]
  end

  expose(:county_names) { current_chapter.counties.map(&:name) }

  def link_date_window(date)
    (date - 7)..(date + 7)
  end

  helper_method :incidents_for_cas
  def incidents_for_cas(cas)
    scope = Incidents::Incident.for_chapter(cas.chapter).with_date_in(link_date_window(cas.incident_date))
    if cas.county_name
      scope = scope.with_county_name(cas.county_name)
    end
    scope.to_a
  end

end