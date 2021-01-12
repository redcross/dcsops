class AddRccareEventIdToIncidentsIncident < ActiveRecord::Migration
  def change
    add_column :incidents_incidents, :rccare_event_id, :string
  end
end
