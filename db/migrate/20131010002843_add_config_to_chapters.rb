class AddConfigToChapters < ActiveRecord::Migration
  def change
    add_column :roster_chapters, :config, :hstore
  end
end
