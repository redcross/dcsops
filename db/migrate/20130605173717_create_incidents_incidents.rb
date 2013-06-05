class CreateIncidentsIncidents < ActiveRecord::Migration
  def change
    create_table :incidents_incidents do |t|
      t.references :chapter, index: true
      t.references :county, index: true
      t.string :incident_number
      t.string :cas_incident_number
      t.date :date
      
      t.integer :units_affected
      t.integer :num_adults
      t.integer :num_children
      t.integer :num_families
      t.integer :num_cases
      t.string :incident_type
      t.string :incident_description
      t.text :narrative_brief
      t.text :narrative

      t.string :address
      t.string :cross_street
      t.string :city
      t.string :state
      t.string :zip
      t.decimal :lat
      t.decimal :lng

      t.timestamps
    end
  end
end
