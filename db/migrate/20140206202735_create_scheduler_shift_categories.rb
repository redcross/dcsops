class CreateSchedulerShiftCategories < ActiveRecord::Migration
  def change
    create_table :scheduler_shift_categories do |t|
      t.references :chapter, index: true
      t.string :name
      t.boolean :show, null: false, default: false
      t.integer :ordinal

      t.timestamps
    end

    add_column :scheduler_shifts, :shift_category_id, :integer
  end
end
