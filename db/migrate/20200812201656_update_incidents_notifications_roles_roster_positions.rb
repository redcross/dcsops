class UpdateIncidentsNotificationsRolesRosterPositions < ActiveRecord::Migration
  def change
    rename_table :incidents_notifications_roles_roster_positions, :incidents_notifications_role_configurations
    add_column :incidents_notifications_role_configurations, :shift_territory_id, :integer
  end
end
