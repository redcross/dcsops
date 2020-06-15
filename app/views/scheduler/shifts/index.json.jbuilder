json.array!(collection) do |scheduler_shift|
  json.extract! scheduler_shift, :name, :abbrev, :shift_time_id, :max_signups, :shift_territory_id
  json.url scheduler_shift_url(scheduler_shift, format: :json)
end