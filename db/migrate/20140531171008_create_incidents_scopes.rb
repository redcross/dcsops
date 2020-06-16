class CreateIncidentsScopes < ActiveRecord::Migration
  class Chapter < ApplicationRecord
    self.table_name = :roster_chapters
  end
  class Scope < ApplicationRecord
    self.table_name = :incidents_scopes
  end

  def change
    create_table :incidents_scopes do |t|
      t.references :chapter
      t.string :url_slug
      t.string :abbrev
      t.string :short_name
      t.string :name
      t.hstore :config

      t.timestamps
    end
    add_index :incidents_scopes, [:url_slug], unique: true

    create_table :incidents_scopes_roster_chapters, id: false do |t|
      t.integer :scope_id, null: false
      t.integer :chapter_id, null: false
    end
    add_index :incidents_scopes_roster_chapters, [:scope_id, :chapter_id], unique: true, name: "index_incidents_scopes_roster_chapters"

    reversible do |dir|
      dir.up do
        say_with_time "Create Scopes" do
          scope_attrs = Incidents::Scope.serialized_columns.keys.map(&:to_s)
          Chapter.where.not(id: 0).each do |ch|
            Scope.create! id: ch.id, chapter_id: ch.id, name: ch.name, short_name: ch.short_name, url_slug: ch.url_slug, config: ch.config.slice(*scope_attrs)
          end
        end

        execute "ALTER SEQUENCE incidents_scopes_id_seq RESTART WITH #{(Scope.maximum(:id) || 0)+1}"
      end
    end
  end
end
