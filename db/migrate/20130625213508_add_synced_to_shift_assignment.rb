class AddSyncedToShiftAssignment < ActiveRecord::Migration
  def change
    add_column :scheduler_shift_assignments, :synced, :boolean, default: false
  end
end
