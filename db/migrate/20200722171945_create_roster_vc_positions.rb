class CreateRosterVcPositions < ActiveRecord::Migration
  def change
    create_table :roster_vc_positions do |t|
      t.string :name
      t.references :region
    end
  end
end
