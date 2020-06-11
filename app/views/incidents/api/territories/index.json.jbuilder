json.extract! @territory, :id, :region_id, :name, :dispatch_number, :non_disaster_number
json.region_name @territory.region.name
json.permissions do
  json.create can?(:create, Incidents::Incident.new(region: @territory.region))
end