class CreateLookups < ActiveRecord::Migration
  def change
    create_table :lookups do |t|
      t.references :chapter, index: true
      t.string :scope, index: true
      t.string :name, null: false
      t.string :value, null: false
      t.integer :ordinal

      t.timestamps
    end
  end
end
