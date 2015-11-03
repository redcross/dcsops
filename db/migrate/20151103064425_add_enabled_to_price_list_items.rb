class AddEnabledToPriceListItems < ActiveRecord::Migration
  def change
    add_column :incidents_price_list_items, :enabled, :boolean, default: true, null: false
  end
end
