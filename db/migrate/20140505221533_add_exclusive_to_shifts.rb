class AddExclusiveToShifts < ActiveRecord::Migration
  def change
    add_column :scheduler_shifts, :exclusive, :boolean, default: true, null: false
  end
end
