class CreateIncidentsCases < ActiveRecord::Migration
  def change
    create_table :incidents_cases do |t|
      t.references :incident, index: true
      t.string :cas_incident_number
      t.string :form_901_number
      t.string :first_name
      t.string :last_name
      t.string :address
      t.string :unit
      t.string :city
      t.string :state
      t.string :zip
      t.decimal :lat
      t.decimal :lng
      t.string :phone_number
      t.integer :num_adults
      t.integer :num_children
      t.string :cac_number
      t.decimal :total_amount
      t.text :notes

      t.timestamps
    end
  end
end
