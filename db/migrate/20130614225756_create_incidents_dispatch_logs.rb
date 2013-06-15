class CreateIncidentsDispatchLogs < ActiveRecord::Migration
  def change
    create_table :incidents_dispatch_logs do |t|
      t.string :incident_number
      t.references :chapter, index: true
      t.references :incident, index: true
      t.datetime :received_at
      t.datetime :delivered_at
      t.string :delivered_to
      t.string :incident_type
      t.string :address
      t.string :cross_street
      t.string :county_name
      t.string :displaced
      t.string :services_requested
      t.string :agency
      t.string :contact_name
      t.string :contact_phone
      t.string :caller_id

      t.timestamps
    end
  end
end
