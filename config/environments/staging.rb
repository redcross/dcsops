require File.expand_path('../production.rb', __FILE__)

Scheduler::Application.configure do
  # Same for now, using for splitting environments
  config.action_mailer.delivery_method = :test
  config.logger = Logger.new(STDOUT)
end
