class MoveNumPeopleToIncident < ActiveRecord::Migration
  def change
    execute "ALTER TABLE incidents_dat_incidents DROP num_adults CASCADE, DROP num_children CASCADE, DROP num_families CASCADE"
  end
end
