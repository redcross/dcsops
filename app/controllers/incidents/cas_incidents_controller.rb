class Incidents::CasIncidentsController < Incidents::BaseController
  inherit_resources
  load_and_authorize_resource
  include Searchable

  has_scope :open_cases, type: :boolean, default: true

  protected

  def end_of_association_chain
    super.where(chapter_id: current_chapter)
  end

  def collection
    @_cas_incidents ||= super.preload(:cases, :incident)
  end
end