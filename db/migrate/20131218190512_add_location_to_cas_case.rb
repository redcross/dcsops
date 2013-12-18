class AddLocationToCasCase < ActiveRecord::Migration
  def change
    add_column :incidents_cas_cases, :lat, :decimal
    add_column :incidents_cas_cases, :lng, :decimal
  end
end
