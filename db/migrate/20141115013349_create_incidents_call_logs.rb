class CreateIncidentsCallLogs < ActiveRecord::Migration
  def change
    create_table :incidents_call_logs do |t|
      t.references :chapter, index: true
      t.references :dispatching_chapter, index: true

      t.string :call_type
      t.string :contact_name
      t.string :contact_number
      t.string :address_entry
      t.string :address
      t.string :city
      t.string :state
      t.string :zip
      t.string :county
      t.float :lat
      t.float :lng
      t.string :incident_type
      t.text :services_requested
      t.integer :num_displaced
      t.text :referral_reason

      t.timestamp :call_start

      t.references :incident
      t.references :territory
      t.references :creator

      t.timestamps
    end
  end
end
