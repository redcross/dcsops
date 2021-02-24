class Incidents::ResponsesController < Incidents::BaseController
  
  #respond_to :html, :csv

  has_scope :with_person_in_shift_territories, as: :shift_territory_id, default: ->controller{controller.current_user.primary_shift_territory_id}
  has_scope :date_after, :allow_blank => true, :default => FiscalYear.current.start_date.to_s do |controller, scope, val|
    if not controller.params[:date_before].blank?
      scope.left_outer_joins(:incident).where(incidents_incidents: { date: val..controller.params[:date_before] })
    elsif not val.blank?
      scope.left_outer_joins(:incident).where("incidents_incidents.date > ?", val)
    else
      scope
    end
  end
  has_scope :date_before do |controller, scope, val|
    # This is a hack, I guess, but I don't know how to do it otherwise
    # If there date_after is present, we have to let that scope handle everything
    if not controller.params[:date_after].blank?
      scope
    else
      scope.left_outer_joins(:incident).where("incidents_incidents.date < ?", val)
    end
  end

  expose(:responders) {
    authorize! :show, :responders
    apply_scopes(Incidents::ResponderAssignment).for_region(current_region)
                                                .includes(:incident, :person)
                                                .order('incidents_incidents.date DESC')
                                                .group_by(&:person)
  }

  expose(:max_responses) { 10 }

  helper_method :tooltip_for
  def tooltip_for(response)
    "#{response.incident.to_label} - #{response.humanized_role}"
  end

end