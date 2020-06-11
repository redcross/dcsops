json.array!(@incidents_incidents) do |incidents_incident|
  json.extract! incidents_incident, :region_id, :county_id, :incident_number, :cas_incident_number, :date, :city, :units_affected, :num_adults, :num_children, :num_families, :num_cases, :incident_type, :incident_description, :narrative_brief, :narrative
  json.url incidents_incident_url(incidents_incident, format: :json)
end