class AddOrdinalToShiftTerritories < ActiveRecord::Migration
  def change
    add_column :roster_shift_territories, :ordinal, :integer
  end
end
