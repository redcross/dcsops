class CreateIncidentsCaseAssistanceItems < ActiveRecord::Migration
  def change
    create_table :incidents_case_assistance_items do |t|
      t.references :price_list_item, index: true
      t.references :case, index: true
      t.integer :quantity
      t.decimal :total_price

      t.timestamps
    end
  end
end
