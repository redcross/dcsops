class AddShowInDispatchConsoleToSchedulerShifts < ActiveRecord::Migration
  def change
    add_column :scheduler_shifts, :show_in_dispatch_console, :boolean, default: true, null: false
  end
end
