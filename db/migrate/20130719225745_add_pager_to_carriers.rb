class AddPagerToCarriers < ActiveRecord::Migration
  def change
    add_column :roster_cell_carriers, :pager, :boolean
  end
end
