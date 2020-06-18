class RenameCountyToShiftTerritory < ActiveRecord::Migration
  def change
    rename_table :roster_counties, :roster_shift_territories
    rename_table :roster_county_memberships, :roster_shift_territory_memberships
    rename_table :incidents_response_territories_roster_counties,
      :incidents_response_territories_roster_shift_territories

    rename_column :incidents_incidents, :area_id, :shift_territory_id
    rename_column :incidents_response_territories_roster_shift_territories, :county_id, :shift_territory_id
    rename_column :roster_shift_territory_memberships, :county_id, :shift_territory_id
    rename_column :roster_people, :primary_county_id, :primary_shift_territory_id
    rename_column :scheduler_dispatch_configs, :county_id, :shift_territory_id
    rename_column :scheduler_shifts, :county_id, :shift_territory_id
    rename_column :incidents_report_subscriptions, :county_id, :shift_territory_id
    rename_column :scheduler_shifts, :ignore_county, :ignore_shift_territory
    rename_column :incidents_cas_incidents, :county_name, :county
    rename_column :incidents_dispatch_logs, :county_name, :county

    rename_index :incidents_response_territories_roster_shift_territories,
      "incidents_response_territories_roster_counties_index",
      "incidents_response_territories_roster_shift_territories_index"
  end
# These aren't real migrations, as migrations shouldn't play with data
# however, they do need to be run on production systems and so should be stored
# somewhere in source control.  So I put them here
#
#  production up
#    update roster_roles set grant_name = 'shift_territory_dat_admin' where grant_name = 'county_dat_admin';
#    update roster_roles set grant_name = 'shift_territory_roster' where grant_name = 'county_roster';
#    update roster_roles set grant_name = 'shift_territory_scheduler' where grant_name = 'county_scheduler';
#    update roster_roles set name = 'Shift Territory Dat Admin' where name = 'County Dat Admin';
#    update roster_roles set name = 'Shift Territory Roster' where name = 'County Roster';
#    update roster_roles set name = 'Shift Territory Scheduler' where name = 'County Scheduler';
#
#  end
#
#  def down
#    update roster_roles set grant_name = 'county_dat_admin' where grant_name = 'shift_territory_dat_admin';
#    update roster_roles set grant_name = 'county_roster' where grant_name = 'shift_territory_roster';
#    update roster_roles set grant_name = 'county_scheduler' where grant_name = 'shift_territory_scheduler';
#    update roster_roles set name = 'County Dat Admin' where name = 'Shift Territory Dat Admin';
#    update roster_roles set name = 'County Roster' where name = 'Shift Territory Roster';
#    update roster_roles set name = 'County Scheduler' where name = 'Shift Territory Scheduler';
#  end
end
