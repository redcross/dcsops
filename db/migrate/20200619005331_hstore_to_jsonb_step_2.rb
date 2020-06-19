class HstoreToJsonbStep2 < ActiveRecord::Migration
  def change
    # First rename original hstore columns. These will be unused and can be deleted later once everything is settled.
    rename_column :incidents_dat_incidents,         :resources,   :resources_hstore
    rename_column :incidents_report_subscriptions,  :options,     :options_hstore
    rename_column :incidents_scopes,                :config,      :config_hstore
    rename_column :roster_regions,                  :config,      :config_hstore

    # Then rename new jsonb columns back into original column name, so we can use them normally.
    rename_column :incidents_dat_incidents,         :resources_jsonb,   :resources
    rename_column :incidents_report_subscriptions,  :options_jsonb,     :options
    rename_column :incidents_scopes,                :config_jsonb,      :config
    rename_column :roster_regions,                  :config_jsonb,      :config
  end
end
