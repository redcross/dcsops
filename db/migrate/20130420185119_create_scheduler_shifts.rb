class CreateSchedulerShifts < ActiveRecord::Migration
  def change
    create_table :scheduler_shifts do |t|
      t.string :name
      t.string :abbrev
      t.references :shift_group, index: true
      t.integer :max_signups
      t.references :county, index: true
      t.integer :ordinal
      t.integer :spreadsheet_ordinal

      t.integer :dispatch_role

      t.date :shift_begins
      t.date :shift_ends
      t.date :signups_frozen_before

      t.timestamps
    end
  end
end
