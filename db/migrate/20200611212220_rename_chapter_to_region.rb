class RenameChapterToRegion < ActiveRecord::Migration
  def change
    rename_table :roster_chapters, :roster_regions
    rename_table :incidents_scopes_roster_chapters, :incidents_scopes_roster_regions
    rename_column :homepage_links, :chapter_id, :region_id
    rename_column :incidents_call_logs, :chapter_id, :region_id
    rename_column :incidents_call_logs, :dispatching_chapter_id, :dispatching_region_id
    rename_column :incidents_cas_incidents, :chapter_id, :region_id
    rename_column :incidents_cas_incidents, :chapter_code, :region_code
    rename_column :incidents_dispatch_logs, :chapter_id, :region_id
    rename_column :incidents_event_logs, :chapter_id, :region_id
    rename_column :incidents_incidents, :chapter_id, :region_id
    rename_column :incidents_notifications_events, :chapter_id, :region_id
    rename_column :incidents_notifications_roles, :chapter_id, :region_id
    rename_column :incidents_responder_messages, :chapter_id, :region_id
    rename_column :incidents_scopes, :chapter_id, :region_id
    rename_column :incidents_scopes_roster_regions, :chapter_id, :region_id
    rename_column :incidents_territories, :chapter_id, :region_id
    rename_column :logistics_vehicles, :chapter_id, :region_id
    rename_column :lookups, :chapter_id, :region_id
    rename_column :motds, :chapter_id, :region_id
    rename_column :partners_partners, :chapter_id, :region_id
    rename_column :roster_counties, :chapter_id, :region_id
    rename_column :roster_people, :chapter_id, :region_id
    rename_column :roster_positions, :chapter_id, :region_id
    rename_column :roster_vc_import_data, :chapter_id, :region_id
    rename_column :scheduler_dispatch_configs, :chapter_id, :region_id
    rename_column :scheduler_shift_categories, :chapter_id, :region_id
    rename_column :scheduler_shift_groups, :chapter_id, :region_id
    rename_column :versions, :chapter_id, :region_id

    rename_index :incidents_incidents,
      "index_incidents_incidents_on_chapter_id_id_date",
      "index_incidents_incidents_on_region_id_id_date"
    rename_index :incidents_incidents,
      "index_incidents_incidents_on_chapter_id_incident_number",
      "index_incidents_incidents_on_region_id_incident_number"
    rename_index :incidents_scopes_roster_regions,
      "index_incidents_scopes_roster_chapters",
      "index_incidents_scopes_roster_regions"
    rename_index :roster_people,
      "index_roster_people_on_chapter_active",
      "index_roster_people_on_region_active"
    rename_index :versions,
      "index_versions_on_chapter_id_root_type_root_id",
      "index_versions_on_region_id_root_type_root_id"
  end

# These aren't real migrations, as migrations shouldn't play with data
# however, they do need to be run on production systems and so should be stored
# somewhere in source control.  So I put them here
  #

#
#  production up
#    update roster_roles set grant_name = 'region_config' where grant_name = 'chapter_config';
#    update roster_roles set grant_name = 'region_dat_admin' where grant_name = 'chapter_dat_admin';
#    update roster_roles set grant_name = 'region_scheduler' where grant_name = 'chapter_scheduler';
#    update roster_roles set grant_name = 'region_admin' where grant_name = 'chapter_admin';
#    update roster_roles set name = 'Region Config' where name = 'Chapter Config';
#    update roster_roles set name = 'Region Dat Admin' where name = 'Chapter Dat Admin';
#    update roster_roles set name = 'Region Scheduler' where name = 'Chapter Scheduler';
#    update roster_roles set name = 'Region Admin' where name = 'Chapter Admin';
#    update roster_regions set config = config || hstore('incidents_delegate_region', config -> 'incidents_delegate_chapter');
#    update roster_regions set config = config || hstore('cas_region_codes', config -> 'cas_chapter_codes');
#    update roster_regions set config = delete(config, 'incidents_delegate_chapter');
#    update roster_regions set config = delete(config, 'cas_chapter_codes');
#
#  end
#
#  def down
#    update roster_roles set grant_name = 'chapter_config' where grant_name = 'region_config';
#    update roster_roles set grant_name = 'chapter_dat_admin' where grant_name = 'region_dat_admin';
#    update roster_roles set grant_name = 'chapter_scheduler' where grant_name = 'region_scheduler;
#    update roster_roles set grant_name = 'chapter_admin' where grant_name = 'region_admin';
#    update roster_roles set name = 'Chapter Config' where name = 'Region Config';
#    update roster_roles set name = 'Chapter Dat Admin' where name = 'Region Dat Admin';
#    update roster_roles set name = 'Chapter Scheduler' where name = 'Region Scheduler';
#    update roster_roles set name = 'Chapter Admin' where name = 'Region Admin';
#    update roster_regions set config = config || hstore('incidents_delegate_chapter', config -> 'incidents_delegate_region');
#    update roster_regions set config = config || hstore('cas_chapter_codes', config -> 'cas_region_codes');
#    update roster_regions set config = delete(config, 'incidents_delegate_region');
#    update roster_regions set config = delete(config, 'cas_region_codes');
#
#  end
end
