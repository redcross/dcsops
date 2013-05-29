class CreateSchedulerNotificationSettings < ActiveRecord::Migration
  def change
    create_table :scheduler_notification_settings do |t|
      t.integer :email_advance_hours
      t.integer :sms_advance_hours
      t.integer :sms_only_after, default: 0
      t.integer :sms_only_before, default: (24*3600)

      t.boolean :send_email_invites
      t.string :calendar_api_token

      t.text :shift_notification_phones

      t.boolean :email_swap_requested
      t.boolean :email_all_swaps

      t.boolean :email_calendar_signups

      t.boolean :email_all_shifts_at
      t.boolean :sms_all_shifts_at

      t.date :last_all_shifts_email
      t.date :last_all_shifts_sms


      t.timestamps
    end
  end
end
