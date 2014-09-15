namespace :scheduler_periodic do
  task :send_reminders => [:environment] do
    Scheduler::SendRemindersJob.enqueue
  end

  task :send_daily => [:send_daily_shift_swap]


  task :send_dispatch_roster => [:environment] do
    Raven.capture do
      Roster::Chapter.with_scheduler_dispatch_export_recipient_present.each do |chapter|
        Scheduler::SendDispatchRosterJob.new(chapter, ENV['IF_NEEDED']!='true').perform
      end
    end
  end

  task :send_daily_shift_swap => [:environment] do
    Raven.capture do
      Scheduler::NotificationSetting.where{(email_all_swaps_daily == true)}.each do |setting|
        Scheduler::RemindersMailer.daily_swap_reminder(setting).deliver
      end
    end
  end

  task :upload_hours => [:environment] do
    Raven.capture do
      if ENV['FORCE'] || (Date.current.wday == 0)
        Scheduler::SubmitHoursJob.enqueue_all
      end
    end
  end
end
