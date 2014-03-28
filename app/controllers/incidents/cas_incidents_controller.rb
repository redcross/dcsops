class Incidents::CasIncidentsController < Incidents::BaseController
  inherit_resources
  load_and_authorize_resource
  include Searchable

  has_scope :open_cases, type: :boolean, default: true

  protected

  def collection
    @_cas_incidents ||= super.preload{[cases, incident]}
  end
end