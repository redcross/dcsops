class RemoveWatchfireRoleFromPositions < ActiveRecord::Migration
  def change
    remove_column :roster_positions, :watchfire_role, :string
  end
end
