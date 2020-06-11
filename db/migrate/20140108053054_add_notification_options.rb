class AddNotificationOptions < ActiveRecord::Migration
  class NotificationSubscription < ApplicationRecord
    self.table_name = :incidents_notification_subscriptions
  end

  def change
    add_column :incidents_notification_subscriptions, :options, :hstore
    add_column :incidents_notification_subscriptions, :frequency, :string
    add_column :incidents_notification_subscriptions, :last_sent, :date

    say_with_time "Update Weekly Subscriptions" do
      NotificationSubscription.where{notification_type == 'weekly'}.update_all notification_type: 'report', frequency: 'weekly'
    end
  end
end
