class CreateIncidentsDispatchLogItems < ActiveRecord::Migration
  def change
    create_table :incidents_dispatch_log_items do |t|
      t.references :dispatch_log, index: true
      t.datetime :action_at
      t.string :action_type
      t.string :recipient
      t.string :operator
      t.string :result

      t.timestamps
    end
  end
end
