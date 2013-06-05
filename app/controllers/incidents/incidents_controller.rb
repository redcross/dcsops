class Incidents::IncidentsController < InheritedResources::Base
  defaults finder: :find_by_incident_number

  private


    # Never trust parameters from the scary internet, only allow the white list through.
    def resource_params
      request.get? ? [] : [params.require(:incidents_incident).permit(:county_id, :incident_number, :cas_incident_number,
       :date, :city, :address, :state, :cross_street, :zip, :lat, :lng,
       :units_affected, :num_adults, :num_children, :num_families, :num_cases, 
       :incident_type, :incident_description, :narrative_brief, :narrative).merge!({chapter_id: current_user.chapter_id})]
    end
end
