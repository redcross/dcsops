class AddDispatchContactToIncident < ActiveRecord::Migration
  def change
    add_column :incidents_incidents, :current_dispatch_contact_id, :integer
    add_column :incidents_incidents, :dispatch_contact_due_at, :timestamp
  end
end
