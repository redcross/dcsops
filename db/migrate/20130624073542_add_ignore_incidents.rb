class AddIgnoreIncidents < ActiveRecord::Migration
  def change
    add_column :incidents_incidents, :ignore_incident_report, :boolean
  end
end
