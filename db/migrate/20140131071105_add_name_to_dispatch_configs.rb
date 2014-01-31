class AddNameToDispatchConfigs < ActiveRecord::Migration
  def up
    add_column :scheduler_dispatch_configs, :name, :string
    execute <<-SQL
      UPDATE scheduler_dispatch_configs dc
      SET name=(SELECT name FROM roster_counties c WHERE dc.id=c.id LIMIT 1),
          county_id=dc.id
    SQL
    execute <<-SQL
      SELECT setval(pg_get_serial_sequence('scheduler_dispatch_configs', 'id'), (SELECT MAX(id) FROM scheduler_dispatch_configs))
    SQL

    change_column :scheduler_dispatch_configs, :name, :string, null: false
  end

  def down
    remove_column :scheduler_dispatch_configs, :name
  end
end
