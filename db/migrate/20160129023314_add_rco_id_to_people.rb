class AddRcoIdToPeople < ActiveRecord::Migration
  def change
    add_column :roster_people, :rco_id, :string
  end
end
