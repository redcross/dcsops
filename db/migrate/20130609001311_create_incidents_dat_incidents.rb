class CreateIncidentsDatIncidents < ActiveRecord::Migration
  def change
    create_table :incidents_dat_incidents do |t|
      t.references :incident
      t.string :incident_type
      t.string :incident_call_type
      t.string :verified_by

      t.integer :num_adults
      t.integer :num_children
      t.integer :num_families

      t.integer :num_people_injured
      t.integer :num_people_hospitalized
      t.integer :num_people_deceased

      t.datetime :responder_notified
      t.datetime :responder_arrived
      t.datetime :responder_departed

      t.string :address
      t.string :cross_street
      t.string :neighborhood
      t.string :city
      t.string :state
      t.string :zip
      t.decimal :lat
      t.decimal :lng

      t.integer :units_total
      t.integer :units_affected
      t.integer :units_minor
      t.integer :units_major
      t.integer :units_destroyed

      t.text :narrative
      t.text :services

      t.timestamps
    end

    add_index :incidents_dat_incidents, :incident_id, unique: true
  end
end
