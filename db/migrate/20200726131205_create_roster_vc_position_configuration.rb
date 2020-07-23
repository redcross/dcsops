class CreateRosterVcPositionConfiguration < ActiveRecord::Migration
  def change
    create_table :roster_vc_position_configurations do |t|
      t.references :shift_territory
      t.references :position
      t.references :vc_position
    end
  end
end
