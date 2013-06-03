class AddAuthorizationModels < ActiveRecord::Migration
  def change
    add_column :roster_positions, :grants_role, :string
    add_column :roster_positions, :role_scope, :text # Serialized column
    add_column :roster_positions, :hidden, :boolean, default: false
  end
end
