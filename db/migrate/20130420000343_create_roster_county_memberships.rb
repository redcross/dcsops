class CreateRosterCountyMemberships < ActiveRecord::Migration
  def change
    create_table :roster_counties_people, id: false do |t|
      t.references :county
      t.references :person
    end
  end
end
