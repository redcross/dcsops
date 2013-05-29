class CreateRosterPositionMemberships < ActiveRecord::Migration
  def change
    create_table :roster_people_positions, id: false do |t|
      t.references :position
      t.references :person
    end
  end
end
