class Incidents::ResponsesController < Incidents::BaseController

  has_scope :with_person_in_shift_territories, as: :shift_territory_id, default: ->controller{controller.current_user.primary_shift_territory_id}
  has_scope :response_in_last, default: 180 do |controller, scope, val|
    date = Date.current - val.to_i
    scope.joins{incident.outer}.where{incident.date >= date}
  end

  expose(:responders) {
    authorize! :show, :responders
    apply_scopes(Incidents::ResponderAssignment).for_region(current_region)
                                                .includes{[incident, person]}
                                                .order('incident.date DESC')
                                                .group_by(&:person)
  }

  expose(:max_responses) { 10 }

  helper_method :tooltip_for
  def tooltip_for(response)
    "#{response.incident.to_label} - #{response.humanized_role}"
  end

end