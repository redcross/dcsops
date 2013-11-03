class FixIncidentIndexes < ActiveRecord::Migration
  def change
    remove_index :incidents_incidents, :incident_number
    add_index :incidents_incidents, [:chapter_id, :incident_number], unique: true
  end
end
