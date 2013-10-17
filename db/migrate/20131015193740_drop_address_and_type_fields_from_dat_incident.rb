class DropAddressAndTypeFieldsFromDatIncident < ActiveRecord::Migration
  def change
    [:incident_type, :address, :city, :state, :zip, :lat, :lng, :neighborhood, :county].each do |col|
      remove_column :incidents_dat_incidents, col
    end
  end
end
