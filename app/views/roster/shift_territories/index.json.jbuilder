json.array!(collection) do |roster_shift_territory|
  json.extract! roster_shift_territory, :name, :shift_territory_code, :fips_code, :gis_name
  json.url roster_shift_territory_url(roster_shift_territory, format: :json)
end