class Incidents::IncidentsController < InheritedResources::Base
  defaults finder: :find_by_incident_number!

  private


    # Never trust parameters from the scary internet, only allow the white list through.
    def resource_params
      keys = [:county_id, :cas_incident_number, :incident_call_type, :team_lead_id,
             :date, :city, :address, :state, :cross_street, :zip, :lat, :lng,
             :units_affected, :num_adults, :num_children, :num_families, :num_cases, 
             :incident_type, :incident_description, :narrative_brief, :narrative]

      keys << :incident_number if params[:action] == 'create'


      request.get? ? [] : [params.require(:incidents_incident).permit(*keys).merge!({chapter_id: current_user.chapter_id})]
    end
end
