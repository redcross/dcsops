class AddVcPositionsFilterToChapters < ActiveRecord::Migration
  def change
    add_column :roster_chapters, :vc_position_filter, :string
  end
end
