class CreateIncidentsNotificationsRoleScopes < ActiveRecord::Migration
  def change
    create_table :incidents_notifications_role_scopes do |t|
      t.integer :role_id
      t.string :level
      t.string :value

      t.timestamps
    end
    add_index :incidents_notifications_role_scopes, [:role_id]
    remove_column :incidents_notifications_roles, :scope
  end
end
