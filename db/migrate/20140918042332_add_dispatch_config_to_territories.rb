class AddDispatchConfigToTerritories < ActiveRecord::Migration
  def change
    add_column :incidents_territories, :dispatch_config_id, :integer
  end
end
