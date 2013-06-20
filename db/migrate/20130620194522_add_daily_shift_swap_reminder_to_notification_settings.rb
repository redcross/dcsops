class AddDailyShiftSwapReminderToNotificationSettings < ActiveRecord::Migration
  def change
    add_column :scheduler_notification_settings, :email_all_swaps_daily, :boolean
  end
end
