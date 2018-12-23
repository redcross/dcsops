class AddUnitsNotLivableUnitsLivableToDatIncident < ActiveRecord::Migration
  def change
    add_column :incidents_dat_incidents, :units_not_livable, :integer
    add_column :incidents_dat_incidents, :units_livable, :integer
  end
end
