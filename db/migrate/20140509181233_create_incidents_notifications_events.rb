class CreateIncidentsNotificationsEvents < ActiveRecord::Migration
  def change
    create_table :incidents_notifications_events do |t|
      t.references :chapter, index: true
      t.string :name
      t.string :description
      t.string :event_type
      t.string :event
      t.integer :ordinal

      t.timestamps
    end
  end
end
