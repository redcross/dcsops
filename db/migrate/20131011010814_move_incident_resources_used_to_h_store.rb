class MoveIncidentResourcesUsedToHStore < ActiveRecord::Migration
  class DATIncident < ApplicationRecord
    self.table_name = "incidents_dat_incidents"
  end

  def change
    add_column :incidents_dat_incidents, :resources, :hstore
    DATIncident.find_each do |di|
      di.resources = {blankets: di.blankets_used, comfort_kits: di.comfort_kits_used}
      di.save!
    end
    remove_column :incidents_dat_incidents, :blankets_used
    remove_column :incidents_dat_incidents, :comfort_kits_used
  end
end
