class AddChapterIdToCasIncident < ActiveRecord::Migration
  def change
    add_column :incidents_cas_incidents, :chapter_id, :integer
    add_column :incidents_cas_incidents, :chapter_code, :string
  end
end
