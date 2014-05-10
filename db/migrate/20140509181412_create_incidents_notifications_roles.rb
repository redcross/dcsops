class CreateIncidentsNotificationsRoles < ActiveRecord::Migration
  def change
    create_table :incidents_notifications_roles do |t|
      t.references :chapter
      t.string :name
      t.string :scope

      t.timestamps
    end

    create_table :incidents_notifications_roles_roster_positions, id: false do |t|
      t.integer :role_id, null: false
      t.integer :position_id, null: false
    end
    add_index :incidents_notifications_roles_roster_positions, [:role_id, :position_id], unique: true, name: "index_incidents_notifications_roles_roster_positions"

    create_table :incidents_notifications_roles_scheduler_shifts, id: false do |t|
      t.integer :role_id, null: false
      t.integer :shift_id, null: false
    end
    add_index :incidents_notifications_roles_scheduler_shifts, [:role_id, :shift_id], unique: true, name: "index_incidents_notifications_roles_scheduler_shifts"
  end
end
