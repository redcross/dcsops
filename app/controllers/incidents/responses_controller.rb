class Incidents::ResponsesController < Incidents::BaseController

  def responders
    authorize! :show, :responders
  end

  expose(:county) {
    params[:county_id] ? Roster::County.find(params[:county_id]) : current_user.primary_county
  }

  expose(:responder_assignments) {
    Incidents::ResponderAssignment.joins{[person.county_memberships]}.includes{[incident.dat_incident, person]}.order('incidents_incidents.date desc, incidents_incidents.incident_number desc').where{person.county_memberships.county_id == my{county.try :id}}.select{|r| r.incident and r.person}
  }

  expose(:responders) {
    responder_assignments.sort_by{|a| a.person.last_name}.group_by(&:person)
  }

  helper_method :tooltip_for
  def tooltip_for(response)
    #pp response and return unless response.incident
    "#{response.incident.to_label} - #{response.humanized_role}"
  end

end