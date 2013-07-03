class AddServicesFieldsToDatIncident < ActiveRecord::Migration
  def change
    add_column :incidents_dat_incidents, :languages, :text
  end
end
