class CreateRosterCellCarriers < ActiveRecord::Migration
  def change
    create_table :roster_cell_carriers do |t|
      t.string :name
      t.string :sms_gateway

      t.timestamps
    end
  end
end
