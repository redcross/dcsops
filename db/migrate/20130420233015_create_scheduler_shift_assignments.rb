class CreateSchedulerShiftAssignments < ActiveRecord::Migration
  def change
    create_table :scheduler_shift_assignments do |t|
      t.references :person, index: true
      t.references :shift, index: true
      t.date :date

      t.boolean :email_invite_sent, default: false
      t.boolean :email_reminder_sent, default: false
      t.boolean :sms_reminder_sent, default: false

      t.boolean :available_for_swap, default: false

      t.timestamps
    end
  end
end
