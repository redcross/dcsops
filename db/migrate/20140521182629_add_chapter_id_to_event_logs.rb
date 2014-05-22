class AddChapterIdToEventLogs < ActiveRecord::Migration
  def change
    add_column :incidents_event_logs, :chapter_id, :integer

    execute "UPDATE incidents_event_logs SET chapter_id=(select chapter_id from incidents_incidents i where i.id=incident_id)"

    add_index :incidents_event_logs, :chapter_id
  end
end
