class AddNumFirstRespondersToIncidentsDatIncidents < ActiveRecord::Migration
  def change
    add_column :incidents_dat_incidents, :num_first_responders, :integer
  end
end
