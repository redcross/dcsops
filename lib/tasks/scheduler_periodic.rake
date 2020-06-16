namespace :scheduler_periodic do
  task :send_reminders => [:environment] do
    begin
      Raven.capture do
        Scheduler::SendRemindersJob.enqueue
      end
    rescue => e

    end
  end

  task :send_daily => [:send_daily_shift_swap]


  task :send_dispatch_roster => [:environment] do
    begin
      Raven.capture do
        Roster::Region.with_scheduler_dispatch_export_recipient_present.each do |region|
          Scheduler::SendDispatchRosterJob.new(region, ENV['IF_NEEDED']!='true').perform
        end
      end
    rescue => e

    end
  end

  task :send_daily_shift_swap => [:environment] do
    begin
      Raven.capture do
        Scheduler::NotificationSetting.where(email_all_swaps_daily: true).each do |setting|
          Scheduler::RemindersMailer.daily_swap_reminder(setting).deliver
        end
      end
    rescue => e

    end
  end

  task :upload_hours => [:environment] do
    begin
      Raven.capture do
        if ENV['FORCE'] || (Date.current.wday == 0)
          Scheduler::SubmitHoursJob.enqueue_all
        end
      end
    rescue => e

    end
  end
end
