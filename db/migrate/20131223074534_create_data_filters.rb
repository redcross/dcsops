class CreateDataFilters < ActiveRecord::Migration
  def change
    create_table :data_filters do |t|
      t.string :model
      t.string :field
      t.string :pattern_raw

      t.timestamps
    end
  end
end
