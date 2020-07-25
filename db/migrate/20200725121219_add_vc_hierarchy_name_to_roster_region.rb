class AddVcHierarchyNameToRosterRegion < ActiveRecord::Migration
  def change
    add_column :roster_regions, :vc_hierarchy_name, :string
  end
end
