class Incidents::ResponsesController < Incidents::BaseController

  def responders
    authorize! :show, :responders
  end

  has_scope :with_person_in_counties, as: :county_id, default: ->controller{controller.current_user.primary_county_id}
  has_scope :response_in_last, default: 180 do |controller, scope, val|
    date = Date.current - val.to_i
    scope.left_outer_joins(:incident).where(incident: { date: date..DateTime::Infinity.new })
  end

  expose(:responders) {
    apply_scopes(Incidents::ResponderAssignment).for_chapter(current_chapter)
                                                .includes(:incident, :person)
                                                .order('incident.date DESC')
                                                .group_by(&:person)
  }

  expose(:max_responses) { 10 }

  helper_method :tooltip_for
  def tooltip_for(response)
    "#{response.incident.to_label} - #{response.humanized_role}"
  end

end