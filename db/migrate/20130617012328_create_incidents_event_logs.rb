class CreateIncidentsEventLogs < ActiveRecord::Migration
  def change
    create_table :incidents_event_logs do |t|
      t.references :incident, index: true
      t.references :person, index: true
      t.string :event
      t.timestamp :event_time
      t.text :message

      t.timestamps
    end
  end
end
