class AddDisabledToShiftCategories < ActiveRecord::Migration
  def change
    add_column :scheduler_shift_categories, :enabled, :boolean, default: true, null: false
  end
end
