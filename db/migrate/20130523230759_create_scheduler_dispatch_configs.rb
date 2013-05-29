class CreateSchedulerDispatchConfigs < ActiveRecord::Migration
  def change
    create_table :scheduler_dispatch_configs do |t|
      t.references :county, index: true
      t.references :backup_first, index: true
      t.references :backup_second, index: true
      t.references :backup_third, index: true
      t.references :backup_fourth, index: true

      t.boolean :is_active

      t.timestamps
    end

    create_table :scheduler_dispatch_configs_admin_notifications, id: false do |t|
      t.references :scheduler_dispatch_config
      t.references :roster_person
    end
  end
end
