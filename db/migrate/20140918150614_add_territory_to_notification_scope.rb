class AddTerritoryToNotificationScope < ActiveRecord::Migration
  def change
    add_column :incidents_notifications_role_scopes, :territory_id, :integer
  end
end
