class Incidents::IncidentPresenter < SimpleDelegator
  # Make sure we look and behave as much like a real Incident as possible,
  # otherwise things like CanCan and ActiveRecord will complain vehemently.
  undef :class, :is_a?

  include ActionView::Helpers::TextHelper

  def total_assistance_amount
    cases.map(&:total_amount).compact.sum
  end

  def full_address
    [[address, city, state].compact.join(", "), zip].compact.join "  "
  end

  def latest_event_log
    event_logs.detect{|l| !%w(note dispatch_note).include?(l.event)}
  end

  def time_to_on_scene
    received = self.event_logs.where(event: ['dispatch_received', 'dispatch_note', 'dat_received', 'dispatch_relayed', 'responders_identified']).order(:event_time).first
    on_scene = self.event_logs.where(event: ['dat_on_scene']).first

    if received and on_scene
      on_scene.event_time - received.event_time
    end
  end

  def incident_status
    latest_event_log.try(:event)
  end
  
  def incident_status_title
    event = latest_event_log.try(:event)
    event && Incidents::EventLog::EVENTS_TO_DESCRIPTIONS[event]
  end

  def shift_territory_name
    shift_territory.try :name
  end

  def services_description
    services = dat_incident.try(:services) and services.map(&:titleize).to_sentence
  end

  def resources_description
    (dat_incident.resources || []).map{|name, quantity| 
      quantity = quantity.to_i
      if quantity > 0 
        name = name.titleize.singularize
        pluralize(quantity, name)
      end
    }.compact.to_sentence
  end

  def demographics_description
    {unit: dat_incident.try(:units_total), adult: num_adults, child: num_children, first_responder: dat_incident.try(:num_first_responders)}.select{|k, v| v && v > 0}.map{|k, v| pluralize(v, k.to_s.humanize)}.join ", "
  end

  def on_scene_responders
    all_responder_assignments.to_a.count{|r| r.on_scene }
  end

  def available_responders
    all_responder_assignments.select(&:was_available)
  end

  def unavailable_responders
    all_responder_assignments.reject(&:was_available)
  end

  def team_lead_name
    team_lead.try(:person).try(:full_name)
  end

  def map_url
    "https://maps.google.com/maps?q=#{lat}+#{lng}+"
  end

  def routes
    Rails.application.routes.url_helpers
  end

  def path
    routes.incidents_region_incident_path(region, to_param)
  end

  def submit_path
    param = to_param || "INVALID"
    region.incidents_report_editable ? routes.incidents_region_incident_path(region, param) : routes.new_incidents_region_incident_dat_path(region, param)
  end

  def invalid_path
    routes.mark_invalid_incidents_region_incident_path(region, __getobj__)
  end
end
