class CreateIncidentsPartnerUses < ActiveRecord::Migration
  def change
    create_table :incidents_partner_uses do |t|
      t.references :incident, index: true
      t.references :partner, index: true
      t.string :role
      t.decimal :hotel_rate
      t.integer :hotel_rooms
      t.integer :meals_served

      t.timestamps
    end
  end
end
