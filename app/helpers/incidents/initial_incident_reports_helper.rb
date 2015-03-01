module Incidents::InitialIncidentReportsHelper

  def timeline_time event
    tl = resource.incident.event_logs.find_by event: event
    tl && tl.event_time.to_s(:mdy_time)
  end

  def humanized_triggers
    triggers = resource.triggers || []
    triggers.map{|trig| t trig, scope: "incidents.initial_incident_reports.form.triggers" }.to_sentence
  end

end