json.array!(collection) do |roster_chapter|
  json.extract! roster_chapter, :id, :name, :code, :short_name
  json.url roster_chapter_url(roster_chapter, format: :json)
end