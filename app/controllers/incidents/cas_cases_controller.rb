class Incidents::CasCasesController < Incidents::BaseController
  inherit_resources
  load_and_authorize_resource

  belongs_to :cas_incident, finder: :find_by_cas_incident_number!, parent_class: Incidents::CasIncident
  defaults finder: :find_by_case_number!

  custom_actions resource: [:narrative]

  def narrative
    #narrative! do
      render layout: false
    #end
  end

  private

  helper_method :formatted_narrative
  def formatted_narrative
    (resource.narrative || 'No Narrative Provided').gsub(/^(\[[^\]]+\])/, "\n\n#{'\1'}\n")
  end
end