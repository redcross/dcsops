class CreateSchedulerShiftGroups < ActiveRecord::Migration
  def change
    create_table :scheduler_shift_groups do |t|
      t.string :name
      t.string :period
      t.integer :start_offset
      t.integer :end_offset
      t.references :chapter, index: true

      t.timestamps
    end
  end
end
