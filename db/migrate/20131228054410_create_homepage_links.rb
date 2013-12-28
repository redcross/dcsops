class CreateHomepageLinks < ActiveRecord::Migration
  def change
    create_table :homepage_links do |t|
      t.references :chapter, index: true
      t.string :name
      t.text :description
      t.string :icon
      t.string :url
      t.attachment :file
      t.integer :ordinal
      t.string :group
      t.integer :group_ordinal

      t.timestamps
    end

    create_table :homepage_links_roster_roles, id: false do |t|
      t.references :role
      t.references :homepage_link
    end
  end
end
