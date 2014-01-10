class AddSourceLookupToEventLogs < ActiveRecord::Migration
  def change
    add_column :incidents_event_logs, :source_id, :integer
  end
end
