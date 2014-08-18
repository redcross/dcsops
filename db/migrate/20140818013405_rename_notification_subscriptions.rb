class RenameNotificationSubscriptions < ActiveRecord::Migration
  def change
    rename_table :incidents_notification_subscriptions, :incidents_report_subscriptions
    rename_column :incidents_report_subscriptions, :notification_type, :report_type
  end
end
