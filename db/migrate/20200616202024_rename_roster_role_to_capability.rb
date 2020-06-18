class RenameRosterRoleToCapability < ActiveRecord::Migration
  def change
    rename_table :roster_role_memberships, :roster_capability_memberships
    rename_table :roster_role_scopes, :roster_capability_scopes
    rename_table :roster_roles, :roster_capabilities

    rename_column :roster_capability_memberships, :role_id, :capability_id
    rename_column :roster_capability_scopes, :role_membership_id, :capability_membership_id

  end
end
