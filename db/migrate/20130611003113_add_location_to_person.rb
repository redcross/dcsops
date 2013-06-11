class AddLocationToPerson < ActiveRecord::Migration
  def change
    add_column :roster_people, :lat, :decimal
    add_column :roster_people, :lng, :decimal
  end
end
