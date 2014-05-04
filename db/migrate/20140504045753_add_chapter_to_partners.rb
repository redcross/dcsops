class AddChapterToPartners < ActiveRecord::Migration
  def change
    add_column :partners_partners, :chapter_id, :integer
    add_index :partners_partners, [:chapter_id]
    execute "UPDATE partners_partners SET chapter_id=1"
  end
end
