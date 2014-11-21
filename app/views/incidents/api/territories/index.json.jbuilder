json.extract! @territory, :id, :chapter_id, :name, :dispatch_number, :non_disaster_number
json.region_name @territory.chapter.name
json.permissions do
  json.create can?(:create, Incidents::Incident.new(chapter: @territory.chapter))
end