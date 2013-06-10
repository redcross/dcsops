class CreateIncidentsIncidents < ActiveRecord::Migration
  def change
    create_table :incidents_incidents do |t|
      t.references :chapter, index: true
      t.references :county, index: true
      t.string :incident_number
      t.string :incident_type
      t.string :cas_incident_number
      t.date :date

      t.integer :num_adults
      t.integer :num_children
      t.integer :num_families
      t.integer :num_cases

      t.string :incident_description
      t.text :narrative_brief
      t.text :narrative

      t.string :address
      t.string :cross_street
      t.string :neighborhood
      t.string :city
      t.string :state
      t.string :zip
      t.decimal :lat
      t.decimal :lng

      t.string :idat_incident_id
      t.string :idat_incident_rev
      t.timestamp :last_idat_sync

      t.timestamps
    end

    add_index :incidents_incidents, :incident_number, unique: true
  end
end
