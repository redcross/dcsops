class CreateIncidentsCasCases < ActiveRecord::Migration
  def change
    create_table :incidents_cas_cases do |t|
      t.references :cas_incident, index: true
      t.string :case_number
      t.integer :num_clients
      t.string :family_name
      t.date :case_last_updated
      t.date :case_opened
      t.boolean :case_is_open
      t.string :language
      t.text :narrative
      t.string :address
      t.string :city
      t.string :state
      t.string :post_incident_plans
      t.text :notes
      t.timestamp :last_import

      t.timestamps
    end
  end
end
