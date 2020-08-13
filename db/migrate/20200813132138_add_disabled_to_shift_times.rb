class AddDisabledToShiftTimes < ActiveRecord::Migration
  def change
    add_column :scheduler_shift_times, :enabled, :boolean, default: true, null: false
  end
end
