json.array!(@scheduler_shift_times) do |scheduler_shift_time|
  json.extract! scheduler_shift_time, :name, :period, :start_offset, :end_offset, :region_id
  json.url scheduler_shift_time_url(scheduler_shift_time, format: :json)
end