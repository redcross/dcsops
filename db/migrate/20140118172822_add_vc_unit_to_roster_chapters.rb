class AddVcUnitToRosterChapters < ActiveRecord::Migration
  def change
    add_column :roster_chapters, :vc_unit, :integer
  end
end
