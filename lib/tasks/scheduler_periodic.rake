namespace :scheduler do
  task :send_reminders => [:send_invites, :send_email, :send_sms, :send_daily_email, :send_daily_sms]

  task :send_invites => [:environment] do
    Scheduler::ShiftAssignment.needs_email_invite.find_each do |assignment|
      Scheduler::RemindersMailer.email_invite(assignment)
      assignment.update_attribute :email_invite_sent, true
    end
  end

  task :send_email => [:environment] do
    Scheduler::ShiftAssignment.needs_email_reminder.find_each do |assignment|
      Scheduler::RemindersMailer.email_reminder(assignment).deliver
      assignment.update_attribute(:email_reminder_sent, true) # don't fail!
    end
  end

  task :send_sms => [:environment] do
    Scheduler::ShiftAssignment.needs_sms_reminder.find_each do |assignment|
      Scheduler::RemindersMailer.sms_reminder(assignment).deliver
      assignment.update_attribute(:sms_reminder_sent, true) # don't fail!
    end
  end

  task :send_daily_email => [:environment] do
    now = DateTime.now.in_time_zone
    Scheduler::NotificationSetting.needs_daily_email.find_each do |setting|
      Scheduler::RemindersMailer.daily_email_reminder(setting).deliver
      setting.update_attribute(:last_all_shifts_email, now) # don't fail!
    end
  end

  task :send_daily_sms => [:environment] do
    now = DateTime.now.in_time_zone
    Scheduler::NotificationSetting.needs_daily_sms.find_each do |setting|
      Scheduler::RemindersMailer.daily_sms_reminder(setting).deliver
      setting.update_attribute(:last_all_shifts_sms, now) # don't fail!
    end
  end

  task :send_dispatch_roster => [:environment] do
    Roster::Chapter.each do |ch|

    end
  end
end