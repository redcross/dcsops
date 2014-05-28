class AddUrlSlugToChapters < ActiveRecord::Migration
  def change
    add_column :roster_chapters, :url_slug, :string
    add_index :roster_chapters, :url_slug, unique: true
  end
end
