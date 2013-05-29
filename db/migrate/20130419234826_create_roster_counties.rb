class CreateRosterCounties < ActiveRecord::Migration
  def change
    create_table :roster_counties do |t|
      t.references :chapter
      t.string :name
      t.string :abbrev
      t.string :county_code
      t.string :fips_code
      t.string :gis_name
      t.string :vc_regex_raw

      t.timestamps
    end
  end
end
