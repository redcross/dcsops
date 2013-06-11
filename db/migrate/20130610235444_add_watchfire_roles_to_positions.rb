class AddWatchfireRolesToPositions < ActiveRecord::Migration
  def change
    add_column :roster_positions, :watchfire_role, :string
  end
end
