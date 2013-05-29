json.array!(@scheduler_flex_schedules) do |scheduler_flex_schedule|
  json.extract! scheduler_flex_schedule, :person_id
  json.url scheduler_flex_schedule_url(scheduler_flex_schedule, format: :json)
end