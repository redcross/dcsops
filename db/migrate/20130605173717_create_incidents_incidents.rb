class CreateIncidentsIncidents < ActiveRecord::Migration
  def change
    create_table :incidents_incidents do |t|
      t.references :chapter, index: true
      t.references :county, index: true
      t.string :incident_number
      t.string :incident_type
      t.string :incident_call_type
      t.string :cas_incident_number
      t.date :date
      
      t.integer :units_total
      t.integer :units_affected
      t.integer :units_minor
      t.integer :units_major
      t.integer :units_destroyed

      t.integer :num_adults
      t.integer :num_children
      t.integer :num_families
      t.integer :num_cases

      t.integer :num_people_injured
      t.integer :num_people_hospitalized
      t.integer :num_people_deceased

      t.datetime :responder_notified
      t.datetime :responder_arrived
      t.datetime :responder_departed

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

      t.string :idat_incident_id
      t.string :idat_incident_rev
      t.timestamp :last_idat_sync

      t.timestamps
    end
  end
end
