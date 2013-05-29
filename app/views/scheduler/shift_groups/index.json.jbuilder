json.array!(@scheduler_shift_groups) do |scheduler_shift_group|
  json.extract! scheduler_shift_group, :name, :period, :start_offset, :end_offset, :chapter_id
  json.url scheduler_shift_group_url(scheduler_shift_group, format: :json)
end