class CreateSchedulerShiftAllowedRoles < ActiveRecord::Migration
  def change
    create_table :roster_positions_scheduler_shifts, id: false do |t|
      t.references :shift
      t.references :position
    end
  end
end
