class AddUnknownDaToDatIncident < ActiveRecord::Migration
  def change
    add_column :incidents_dat_incidents, :units_unknown, :integer, after: :units_destroyed
  end
end
