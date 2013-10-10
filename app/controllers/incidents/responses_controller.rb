class Incidents::ResponsesController < Incidents::BaseController

  def responders
    authorize! :show, :responders
  end

  expose(:county) {
    params[:county_id] ? Roster::County.find(params[:county_id]) : current_user.primary_county
  }

  expose(:responder_assignments) {
    Incidents::ResponderAssignment.joins{[person.county_memberships]}.includes{[incident.dat_incident, person]}.where{person.county_memberships.county_id == my{county.try :id}}.select{|r| r.incident and r.person}
  }

  expose(:responders) {
    today = Date.current
    responder_assignments.sort_by{|a| [a.person.last_name, today-a.incident.date]}.group_by(&:person)
  }

  expose(:max_responses) {
    10
  }

  helper_method :tooltip_for
  def tooltip_for(response)
    #pp response and return unless response.incident
    "#{response.incident.to_label} - #{response.humanized_role}"
  end

end