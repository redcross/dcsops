class CreateIncidentsPriceListItems < ActiveRecord::Migration
  def change
    create_table :incidents_price_list_items do |t|
      t.integer :item_class
      t.string :name
      t.string :type
      t.decimal :unit_price
      t.text :description

      t.timestamps
    end
  end
end
