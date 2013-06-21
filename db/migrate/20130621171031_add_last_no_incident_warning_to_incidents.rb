class AddLastNoIncidentWarningToIncidents < ActiveRecord::Migration
  def change
    add_column :incidents_incidents, :last_no_incident_warning, :timestamp
  end
end
