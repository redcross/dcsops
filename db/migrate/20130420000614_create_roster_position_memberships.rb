class CreateRosterPositionMemberships < ActiveRecord::Migration
  def change
    create_table :roster_position_memberships do |t|
      t.references :position
      t.references :person

      t.boolean :persistent
    end
  end
end
