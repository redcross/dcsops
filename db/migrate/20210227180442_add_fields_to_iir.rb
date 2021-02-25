class AddFieldsToIir < ActiveRecord::Migration[5.2]
  def change
    add_column :incidents_initial_incident_reports, :disaster_type, :string
    add_column :incidents_initial_incident_reports, :chapter, :string
    add_column :incidents_initial_incident_reports, :caller_name, :string
    add_column :incidents_initial_incident_reports, :caller_agency, :string
    add_column :incidents_initial_incident_reports, :potential_impacts, :text
    add_column :incidents_initial_incident_reports, :additional_comments, :text
  end
end
