class AddNewYorkFieldsToDatIncident < ActiveRecord::Migration
  def change
    # Fire incident data fields
    add_column :incidents_dat_incidents, :suspicious_fire, :boolean
    add_column :incidents_dat_incidents, :injuries_black, :integer
    add_column :incidents_dat_incidents, :injuries_red, :integer
    add_column :incidents_dat_incidents, :injuries_yellow, :integer

    add_column :incidents_dat_incidents, :where_started, :string
    add_column :incidents_dat_incidents, :under_control_at, :timestamp
    add_column :incidents_dat_incidents, :box, :string
    add_column :incidents_dat_incidents, :box_at, :string
    add_column :incidents_dat_incidents, :battalion, :string
    add_column :incidents_dat_incidents, :num_alarms, :integer

    add_column :incidents_dat_incidents, :size_up, :string
    add_column :incidents_dat_incidents, :num_exposures, :integer

    # Vacate Fields
    add_column :incidents_dat_incidents, :vacate_type, :string
    add_column :incidents_dat_incidents, :vacate_number, :string

    # General Fields
    add_column :incidents_dat_incidents, :num_people_missing, :integer, after: :num_people_deceased
    add_column :incidents_dat_incidents, :hazardous_materials, :string

  end
end
