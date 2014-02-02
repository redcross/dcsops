class ChangeCasIncidentForeignKey < ActiveRecord::Migration
  def change
    add_index :incidents_cas_incidents, [:cas_incident_number], unique: true
    add_index :incidents_incidents, [:cas_incident_number]
    remove_column :incidents_cas_incidents, :incident_id
    add_column :incidents_cas_incidents, :ignore_incident, :boolean, default: false, null: false
  end
end
