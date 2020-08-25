class AddIdToIncidentsNotificationsRoleConfigurations < ActiveRecord::Migration
  def change
    add_column :incidents_notifications_role_configurations, :id, :primary_key
  end
end
