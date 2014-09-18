class CreateIncidentsTerritories < ActiveRecord::Migration
  def change
    create_table :incidents_territories do |t|
      t.references :chapter, index: true
      t.string :name
      t.boolean :enabled
      t.boolean :is_default
      t.string :counties, array: true
      t.string :cities, array: true
      t.string :zip_codes, array: true
      t.string :dispatch_number
      t.string :non_disaster_number
      t.text :special_instructions

      t.timestamps
    end

    add_column :incidents_incidents, :territory_id, :integer
  end
end
