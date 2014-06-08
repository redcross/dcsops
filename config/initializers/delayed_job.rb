Delayed::Worker.delay_jobs = !Rails.env.test?
Delayed::Worker.destroy_failed_jobs = false

if !Rails.env.test? && ENV['ENABLE_DJ_WORKER']
  Rails.application.config.after_initialize do
    puts "Starting DJ in background thread"
    Thread.new do
      Delayed::Worker.raise_signal_exceptions = true
      Delayed::Worker.new.start
    end
  end
end