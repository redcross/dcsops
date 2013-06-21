class AddStructureTypeToDatIncidents < ActiveRecord::Migration
  def change
    add_column :incidents_dat_incidents, :structure_type, :string
    remove_column :incidents_dat_incidents, :units_total
  end
end
