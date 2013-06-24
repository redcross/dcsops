class AddCompletedByToDatIncidents < ActiveRecord::Migration
  def change
    add_column :incidents_dat_incidents, :completed_by_id, :integer
  end
end
