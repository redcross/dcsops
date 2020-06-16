class Incidents::IncidentsListController < Incidents::BaseController
  inherit_resources
  respond_to :html, :js
  defaults finder: :find_by_incident_number!, resource_class: Incidents::Incident, collection_name: :incidents
  load_and_authorize_resource :scope
  belongs_to :scope, parent_class: Incidents::Scope, finder: :find_by_url_slug!, param: :region_id
  helper Incidents::MapHelper
  include Searchable, Paginatable

  actions :index

  def map
    params[:q] = {
      date_gteq: FiscalYear.current.start_date.to_s,
      lat_not_null: true,
      lng_not_null: true
    }.merge(params[:q] || {})
    params[:page] = 'all'
    index!
  end

  protected

  has_scope :in_shift_territory, as: :shift_territory_id_eq
  has_scope :county_state_eq do |controller, scope, val|
    county_name, state_name = val.split ", "
    scope.where('LOWER(county) = ?' county_name.downcase).where(state: state_name)
  end

  def resource_path(*args)
    opts = args.extract_options!
    obj = args.first || resource
    incidents_region_incident_path(obj.region, obj, *opts)
  end
  helper_method :resource_path

  def collection
    @_incidents ||= begin
      scope = apply_scopes(super).order(date: :desc, incident_number: :desc)#.preload{[shift_territory, dat_incident, team_lead.person]}
      scope
    end
  end

  def collection_for_stats
    @stats_collection ||= collection.unscope(:limit, :offset, :order, :includes, :joins).with_location
  end
  helper_method :collection_for_stats

  def default_search_params
    {status_in: ['open', 'closed'], date_gteq: FiscalYear.current.start_date}
  end

  def original_url
    request.original_url
  end
  helper_method :original_url

  attr_reader :scope
  helper_method :scope

end
