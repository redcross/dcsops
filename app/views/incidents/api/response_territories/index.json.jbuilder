json.extract! @response_territory, :id, :region_id, :name, :dispatch_number, :non_disaster_number
json.region_name @response_territory.region.name
json.permissions do
  json.create can?(:create, Incidents::Incident.new(region: @response_territory.region))
end