json.array!(collection) do |roster_region|
  json.extract! roster_region, :id, :name, :code, :short_name
  json.url roster_region_url(roster_region, format: :json)
end