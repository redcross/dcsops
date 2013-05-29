class CreateRosterPositions < ActiveRecord::Migration
  def change
    create_table :roster_positions do |t|
      t.references :chapter
      t.string :name
      t.string :vc_regex_raw

      t.boolean :is_county_admin

      t.timestamps
    end
  end
end
