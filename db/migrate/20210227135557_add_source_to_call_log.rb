class AddSourceToCallLog < ActiveRecord::Migration[5.2]
  def change
    add_column :incidents_call_logs, :source_id, :integer
  end
end
