json.array!(@incidents_dat_incidents) do |incidents_dat_incident|
  json.extract! incidents_dat_incident, 
  json.url incidents_dat_incident_url(incidents_dat_incident, format: :json)
end