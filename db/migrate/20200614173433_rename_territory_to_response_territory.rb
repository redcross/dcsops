class RenameTerritoryToResponseTerritory < ActiveRecord::Migration
  def change
    rename_table :incidents_territories, :incidents_response_territories
    rename_table :incidents_territories_roster_counties, :incidents_response_territories_roster_counties

    rename_column :incidents_call_logs, :territory_id, :response_territory_id
    rename_column :incidents_incidents, :territory_id, :response_territory_id
    rename_column :incidents_notifications_role_scopes, :territory_id, :response_territory_id
    rename_column :incidents_response_territories_roster_counties, :territory_id, :response_territory_id

    rename_index :incidents_response_territories_roster_counties,
      "incidents_territories_roster_counties_index",
      "incidents_response_territories_roster_counties_index"
  end
end
