class CreateIncidentsCasIncidents < ActiveRecord::Migration
  def change
    create_table :incidents_cas_incidents do |t|
      t.string :dr_number
      t.string :cas_incident_number
      t.string :cas_name
      t.integer :dr_level
      t.boolean :is_dr
      t.string :county_name
      t.integer :cases_opened
      t.integer :cases_open
      t.integer :cases_closed
      t.integer :cases_with_assistance
      t.integer :cases_service_only
      t.integer :num_clients
      t.integer :phantom_cases
      t.date :last_date_with_open_cases
      t.references :incident, index: true
      t.date :incident_date
      t.text :notes
      t.timestamp :last_import

      t.timestamps
    end
  end
end
