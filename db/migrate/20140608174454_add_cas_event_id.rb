class AddCasEventId < ActiveRecord::Migration
  def change
    add_column :incidents_incidents, :cas_event_id, :integer
    rename_column :incidents_incidents, :cas_incident_number, :cas_event_number
  end
end
