class CreateIncidentsVehicleUses < ActiveRecord::Migration
  def change
    create_table :incidents_vehicle_uses do |t|
      t.references :vehicle, index: true
      t.references :incident, index: true

      t.timestamps
    end
  end
end
