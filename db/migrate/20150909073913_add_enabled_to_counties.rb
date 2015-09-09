class AddEnabledToCounties < ActiveRecord::Migration
  def change
    add_column :roster_counties, :enabled, :boolean, default: true
  end
end
