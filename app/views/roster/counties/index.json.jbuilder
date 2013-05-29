json.array!(collection) do |roster_county|
  json.extract! roster_county, :name, :county_code, :fips_code, :gis_name
  json.url roster_county_url(roster_county, format: :json)
end