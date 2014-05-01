class RemoveCacNumberFields < ActiveRecord::Migration
  def change
    remove_column :incidents_cases, :cac_number
    rename_column :incidents_cases, :cas_incident_number, :cas_case_number
    remove_column :incidents_cases, :form_901_number
  end
end
