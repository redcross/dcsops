json.array!(collection) do |roster_position|
  json.extract! roster_position, :name
  json.url roster_position_url(roster_position, format: :json)
end