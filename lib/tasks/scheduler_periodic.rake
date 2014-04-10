namespace :scheduler_periodic do
  task :send_reminders => [:environment] do
    Scheduler::SendRemindersJob.enqueue chapter.id
  end

  task :send_daily => [:send_daily_shift_swap]


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
end