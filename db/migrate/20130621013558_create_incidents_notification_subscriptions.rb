class CreateIncidentsNotificationSubscriptions < ActiveRecord::Migration
  def change
    create_table :incidents_notification_subscriptions do |t|
      t.references :person, index: true
      t.references :county, index: true
      t.string :notification_type

      t.timestamps
    end
  end
end
