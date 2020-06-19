class HstoreToJsonbStep1 < ActiveRecord::Migration
  def up
    # Add counterpart _jsonb columns to all models that use SerializedColumns
    add_column :incidents_dat_incidents,         :resources_jsonb,  :jsonb, default: {}, null: false
    add_column :incidents_report_subscriptions,  :options_jsonb,    :jsonb, default: {}, null: false
    add_column :incidents_scopes,                :config_jsonb,     :jsonb, default: {}, null: false
    add_column :roster_regions,                  :config_jsonb,     :jsonb, default: {}, null: false

    # Add gin index to new JSONB columns (this drastically speeds up checking
    # for key presence or key/value matches, which we do a lot for these columns)
    add_index  :incidents_dat_incidents,         :resources_jsonb,  using: :gin
    add_index  :incidents_report_subscriptions,  :options_jsonb,    using: :gin
    add_index  :incidents_scopes,                :config_jsonb,     using: :gin
    add_index  :roster_regions,                  :config_jsonb,     using: :gin

    # Open a transaction for all the record re-saves that will happen as we copy data
    ActiveRecord::Base.transaction do
      # Collect all the classes that include Core::SerializedColumns
      [Incidents::DatIncident, Incidents::Scope, Roster::Region].each do |klass|
        # Reload model from database schema to pick up new jsonb column
        klass.reset_column_information
        # Migrate all records
        migrate_serialized_accessors_to_jsonb(klass: klass)
      end
    end
  end

  def down
    remove_column :incidents_dat_incidents,         :resources_jsonb
    remove_column :incidents_report_subscriptions,  :options_jsonb
    remove_column :incidents_scopes,                :config_jsonb
    remove_column :roster_regions,                  :config_jsonb
  end

  def migrate_serialized_accessors_to_jsonb(klass:)
    # Don't update record timestamps for this operation
    # http://stackoverflow.com/a/863366
    ActiveRecord::Base.record_timestamps = false

    # For each record
    puts "Migrating serialized accessors for model: #{klass.name}"
    klass.find_each do |record|
      puts "Processing record #{record.id}…"

      # For each serialized_accessor on this model class
      klass.serialized_columns.each do |name, store_attribute_and_column_object|
        hstore_attribute_name, column_object = store_attribute_and_column_object
        jsonb_attribute_name = "#{hstore_attribute_name}_jsonb"

        print "---> #{hstore_attribute_name}: #{name}… "

        # Read out individual serialized_accessor attribute value, letting SerializedColumn handle type casting
        hstore_value = record.public_send(name)

        # Write attribute into JSONB column, if value is not nil
        record.public_send(jsonb_attribute_name).store(name, hstore_value) unless hstore_value.nil?

        puts "done"
      end

      # Now that all records are migrated, try saving.  We have to set validate to false
      # here because there's some really old records that are no longer valid in the current
      # system.
      record.save!(:validate => false)

      puts "Finished processing record #{record.id}"
    end

    puts "Finished migrating model: #{klass.name}"

  ensure
    ActiveRecord::Base.record_timestamps = true
  end
end
