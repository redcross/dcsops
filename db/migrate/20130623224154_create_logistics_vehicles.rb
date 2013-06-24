class CreateLogisticsVehicles < ActiveRecord::Migration
  def change
    create_table :logistics_vehicles do |t|
      t.references :chapter

      t.string :name
      t.string :category

      t.string :address
      t.string :city
      t.string :state
      t.string :zip
      t.decimal :lat
      t.decimal :lng


      t.timestamps
    end
  end
end
