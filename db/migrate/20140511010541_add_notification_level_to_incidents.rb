class AddNotificationLevelToIncidents < ActiveRecord::Migration
  def change
    add_column :incidents_incidents, :notification_level_id, :integer
    add_column :incidents_incidents, :notification_level_message, :text
  end
end
