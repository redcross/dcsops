class AddRootObjectFieldsToVersions < ActiveRecord::Migration
  class VersionMigrator < ApplicationRecord
    self.table_name = :versions
    serialize :object_changes
    serialize :object

    belongs_to :item, polymorphic: true
  end

  def down
    remove_column :versions, :root_type, :string
    remove_column :versions, :root_id, :integer
    #remove_column :versions, :chapter_id, :integer
  end

  def up
    add_column :versions, :root_type, :string
    add_column :versions, :root_id, :integer
    add_column :versions, :chapter_id, :integer
    execute "ALTER TABLE versions ADD CONSTRAINT root_reference_consistent CHECK((root_type IS NULL AND root_id IS NULL) OR (root_type IS NOT NULL AND root_id IS NOT NULL))"

    say_with_time 'Associating root objects' do

      VersionMigrator.reset_column_information
      VersionMigrator.where.not(item_type: 'Incidents::Incident').includes(:item).find_each do |version|
        unless version.item
          version.destroy
          next
        end
        version.root_type = 'Incidents::Incident'
        version.root_id = version.object.try(:fetch, 'incident_id') || version.object_changes.try(:fetch, "incident_id", []).last

        version.chapter_id = case version.item_type
        when 'Incidents::Incident' then version.object['chapter_id']
        when 'Incidents::DatIncident', 'Incidents::EventLog', 'Incidents::Case' then version.item.incident.chapter_id
        end
        version.save!
      end

    end

    say_with_time 'Updating chapter on Incident changes' do
      VersionMigrator.where(item_type: 'Incidents::Incident').includes(:item).find_each do |version|
        version.chapter_id = version.object.try(:fetch, 'chapter_id') || version.object_changes.try(:fetch, "chapter_id", []).last || version.item.chapter_id
        version.save!
      end
    end

    change_column :versions, :chapter_id, :integer, null: false
  end
end
