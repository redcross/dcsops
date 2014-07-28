class AddDirectlyEnteredAddressToIncident < ActiveRecord::Migration
  def change
    add_column :incidents_incidents, :address_directly_entered, :boolean, null: false, default: false
    execute "UPDATE incidents_incidents SET address_directly_entered='t'"
  end
end
