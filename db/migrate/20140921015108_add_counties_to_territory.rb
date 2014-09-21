class AddCountiesToTerritory < ActiveRecord::Migration
  def change
    create_table :incidents_territories_roster_counties, id: false do |t|
      t.references :territory
      t.references :county
    end
    add_index :incidents_territories_roster_counties, [:territory_id, :county_id]
  end
end
