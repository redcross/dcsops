class Incidents::Api::IncidentsController < Incidents::BaseController
  inherit_resources

  respond_to :kml

  defaults finder: :find_by_incident_number!, resource_class: Incidents::Incident
  load_and_authorize_resource class: resource_class
  helper Incidents::MapHelper

  include NamedQuerySupport
  include Searchable

  around_action :check_already_building_kml, only: :index, if: :kml?

  actions :index

  def index
    expires_in 1.hours, public: false
    if stale?(etag: cache_key, last_modified: collection.maximum(:updated_at))
      index!
    end
  end

  protected

  def check_already_building_kml
    cache = Rails.cache
    build_key = "build_#{cache_key}"

    if cache.exist?(cache_key)
      yield
    elsif start = cache.read(build_key) and start > 60.seconds.ago
      render_busy
    else 
      cache.write(build_key, Time.now)
      yield
      cache.delete build_key
    end
  end

  def render_busy
    headers['Retry-After'] = "30"
    render status: 503, text: 'Currently processing this entity, try again shortly.', content_type: :text
  end

  def kml?; request.format == :kml; end

  expose(:cache_key) { "#{request.format}_#{params[:q]}_count#{collection.count}_#{collection.maximum(:updated_at).to_i}" }
end