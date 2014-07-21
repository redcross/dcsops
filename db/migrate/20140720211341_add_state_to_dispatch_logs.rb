class AddStateToDispatchLogs < ActiveRecord::Migration
  def change
    add_column :incidents_dispatch_logs, :state, :string
  end
end
