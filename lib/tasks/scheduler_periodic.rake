namespace :scheduler_periodic do
  task :send_reminders => [:send_invites, :send_email, :send_sms, :send_daily_email, :send_daily_sms]

  task :send_daily => [:send_daily_shift_swap]

  task :send_invites => [:environment] do
    Raven.capture do
      Roster::Chapter.all.each do |chapter|
        Scheduler::ShiftAssignment.needs_email_invite(chapter).find_each do |assignment|
          Scheduler::RemindersMailer.email_invite(assignment)
          assignment.update_attribute :email_invite_sent, true
        end
      end
    end
  end

  task :send_email => [:environment] do
    Raven.capture do
      Roster::Chapter.all.each do |chapter|
        Scheduler::ShiftAssignment.needs_email_reminder(chapter).each do |assignment|
          Scheduler::RemindersMailer.email_reminder(assignment).deliver
          assignment.update_attribute(:email_reminder_sent, true) # don't fail!
        end
      end
    end
  end

  task :send_sms => [:environment] do
    Raven.capture do
      Roster::Chapter.all.each do |chapter|
        Scheduler::ShiftAssignment.needs_sms_reminder(chapter).each do |assignment|
          Scheduler::RemindersMailer.sms_reminder(assignment).deliver
          assignment.update_attribute(:sms_reminder_sent, true) # don't fail!
        end
      end
    end
  end

  task :send_daily_email => [:environment] do
    Raven.capture do
      Roster::Chapter.all.each do |chapter|
        Scheduler::NotificationSetting.needs_daily_email(chapter).each do |setting|
          Scheduler::RemindersMailer.daily_email_reminder(setting).deliver
          setting.update_attribute(:last_all_shifts_email, chapter.time_zone.today) # don't fail!
        end
      end
    end
  end

  task :send_daily_sms => [:environment] do
    Raven.capture do
      Roster::Chapter.all.each do |chapter|
        Scheduler::NotificationSetting.needs_daily_sms(chapter).each do |setting|
          Scheduler::RemindersMailer.daily_sms_reminder(setting).deliver
          setting.update_attribute(:last_all_shifts_sms, chapter.time_zone.today) # don't fail!
        end
      end
    end
  end

  task :send_dispatch_roster => [:environment] do
    Raven.capture do
      Scheduler::DirectlineMailer.run_if_needed(ENV['IF_NEEDED']!='true')
    end
  end

  task :send_daily_shift_swap => [:environment] do
    Scheduler::NotificationSetting.where{(email_all_swaps_daily == true)}.each do |setting|
      Scheduler::RemindersMailer.daily_swap_reminder(setting).deliver
    end
  end

  task :send_watchfire => [:environment] do
    Raven.capture do
      Roster::Chapter.all.each do |chapter|
        Scheduler::WatchfireExport.new.export chapter
      end
    end
  end
end