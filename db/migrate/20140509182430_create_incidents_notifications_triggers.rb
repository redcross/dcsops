class CreateIncidentsNotificationsTriggers < ActiveRecord::Migration
  def change
    create_table :incidents_notifications_triggers do |t|
      t.references :role, index: true
      t.references :event, index: true
      t.string :template
      t.boolean :use_sms

      t.timestamps
    end
  end
end
