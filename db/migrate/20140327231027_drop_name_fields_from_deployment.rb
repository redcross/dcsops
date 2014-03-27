class DropNameFieldsFromDeployment < ActiveRecord::Migration
  def change
    remove_column :incidents_deployments, :dr_name
    remove_column :incidents_deployments, :dr_number
  end
end
