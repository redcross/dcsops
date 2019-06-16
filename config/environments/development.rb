Scheduler::Application.configure do
  # Settings specified here will take precedence over those in config/application.rb.

  # In the development environment your application's code is reloaded on
  # every request. This slows down response time but is perfect for development
  # since you don't have to restart the web server when you make code changes.
  config.cache_classes = false

  # Do not eager load code on boot.
  config.eager_load = false

  # Show full error reports and disable caching.
  config.consider_all_requests_local       = true
  config.action_controller.perform_caching = false

  # Don't care if the mailer can't send.
  config.action_mailer.raise_delivery_errors = false

  # Print deprecation notices to the Rails logger.
  config.active_support.deprecation = :log

  # Don't send emails
  config.action_mailer.delivery_method = :test

  # Raise an error on page load if there are pending migrations
  config.active_record.migration_error = :page_load

  # Debug mode disables concatenation and preprocessing of assets.
  config.assets.debug = true

  email_path = File.join(Rails.root, 'config', 'email.yml')
   if File.file? email_path
    c = YAML.load(File.read(email_path))
    config.action_mailer.smtp_settings = c['smtp']
  end

  config.action_mailer.default_url_options = {
    :host => "localhost",
    :port => "3000"
  }

  config.action_mailer.interceptors = [DevelopmentMailInterceptor]
end