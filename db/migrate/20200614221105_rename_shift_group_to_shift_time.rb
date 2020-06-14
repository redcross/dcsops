class RenameShiftGroupToShiftTime < ActiveRecord::Migration
  def change
    rename_table :scheduler_shift_groups, :scheduler_shift_times
    rename_table :scheduler_shift_groups_shifts, :scheduler_shift_times_shifts

    rename_column :scheduler_shift_assignments, :shift_group_id, :shift_time_id
    rename_column :scheduler_shift_times_shifts, :shift_group_id, :shift_time_id

    rename_index :scheduler_shift_times_shifts,
      "idx_scheduler_shift_groups_shifts_unique",
      "idx_scheduler_shift_times_shifts_unique"
  end
end
