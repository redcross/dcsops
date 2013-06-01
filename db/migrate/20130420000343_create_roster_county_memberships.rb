class CreateRosterCountyMemberships < ActiveRecord::Migration
  def change
    create_table :roster_county_memberships do |t|
      t.references :county
      t.references :person

      t.boolean :persistent
    end
  end
end
