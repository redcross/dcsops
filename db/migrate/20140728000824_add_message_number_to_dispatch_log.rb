class AddMessageNumberToDispatchLog < ActiveRecord::Migration
  def change
    add_column :incidents_dispatch_logs, :message_number, :string
  end
end
