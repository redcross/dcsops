class RemoveDatIncidentTimelineFields < ActiveRecord::Migration
  def change
    remove_column :incidents_dat_incidents, :responder_notified
    remove_column :incidents_dat_incidents, :responder_arrived
    remove_column :incidents_dat_incidents, :responder_departed
  end
end
