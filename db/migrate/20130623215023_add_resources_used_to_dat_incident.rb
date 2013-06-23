class AddResourcesUsedToDatIncident < ActiveRecord::Migration
  def change
    add_column :incidents_dat_incidents, :comfort_kits_used, :integer
    add_column :incidents_dat_incidents, :blankets_used, :integer
  end
end
