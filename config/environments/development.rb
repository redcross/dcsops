class DisableAssetsLogger
  def initialize(app)
    @app = app
    Rails.application.assets.logger = Logger.new('/dev/null')
  end

  def call(env)
    previous_level = Rails.logger.level
    Rails.logger.level = Logger::ERROR if env['PATH_INFO'].index("/assets/") == 0 or env['PATH_INFO'].index("favicon.ico")
    @app.call(env)
  ensure
    Rails.logger.level = previous_level
  end
end

Scheduler::Application.configure do
  config.middleware.insert_before Rails::Rack::Logger, DisableAssetsLogger
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

  # Raise an error on page load if there are pending migrations
  config.active_record.migration_error = :page_load

  # Debug mode disables concatenation and preprocessing of assets.
  config.assets.debug = true

  email_path = path = File.join(Rails.root, 'config', 'email.yml')

  config.action_mailer.delivery_method = :smtp
  config.action_mailer.smtp_settings = if File.file? path
    c = YAML.load(File.read(email_path))
    c['smtp']
  else
    # Use environment variables
    {
      address: ENV['SMTP_ADDRESS'] || ENV['MAILGUN_SMTP_SERVER'],
      port: ENV['SMTP_PORT'] || ENV['MAILGUN_SMTP_PORT'],
      authentication: ENV['SMTP_AUTHENTICATION'],
      user_name: ENV['SENDGRID_USERNAME'] || ENV['MAILGUN_SMTP_LOGIN'] || ENV['MANDRILL_USERNAME'],
      password: ENV['SENDGRID_PASSWORD'] || ENV['MAILGUN_SMTP_PASSWORD'] || ENV['MANDRILL_APIKEY'],
      domain: ENV['SMTP_DOMAIN'],
      enable_starttls_auto: true
    }
  end

  config.action_mailer.default_url_options = {
    :host => "localhost",
    :port => "3000"
  }
end