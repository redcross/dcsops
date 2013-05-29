json.array!(collection) do |scheduler_shift_assignment|
  json.extract! scheduler_shift_assignment, :person_id, :shift_id, :date
  json.url scheduler_shift_assignment_url(scheduler_shift_assignment, format: :json)
end