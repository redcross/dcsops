require File.expand_path('../boot', __FILE__)

require 'rails/all'

# Assets should be precompiled for production (so we don't need the gems loaded then)
Bundler.require(*Rails.groups(assets: %w(development test)))

require File.expand_path("../../lib/ics_handler", __FILE__)

require File.expand_path("../../lib/exposure", __FILE__)
ActiveSupport.on_load :action_controller do
  include Exposure
end

require 'timeliness/core_ext'

I18n.config.enforce_available_locales = true

module Scheduler
  class Application < Rails::Application
    # Settings in config/environments/* take precedence over those specified here.
    # Application configuration should go into files in config/initializers
    # -- all .rb files in that directory are automatically loaded.

    # Set Time.zone default to the specified zone and make Active Record auto-convert to this zone.
    # Run "rake -D time" for a list of tasks for finding time zone names. Default is UTC.
    config.time_zone = 'Pacific Time (US & Canada)'

    # The default locale is :en and all translations from config/locales/*.rb,yml are auto loaded.
    # config.i18n.load_path += Dir[Rails.root.join('my', 'locales', '*.{rb,yml}').to_s]
    # config.i18n.default_locale = :de
    config.i18n.enforce_available_locales = true

    # In Rails >= 5.0, belongs_to associations are required by default. For
    # backwards compatibility, we disable this behavior (which it is by default,
    # however I prefer to make it explicit by adding this config line).
    config.active_record.belongs_to_required_by_default = false

    ["#{Rails.root}/app/inputs", "#{Rails.root}/lib"].each do |path|
      config.autoload_paths << path
      config.eager_load_paths << path
    end

    config.action_mailer.smtp_settings = {
      address: ENV['SMTP_ADDRESS'] || ENV['MAILGUN_SMTP_SERVER'],
      port: ENV['SMTP_PORT'] || ENV['MAILGUN_SMTP_PORT'],
      authentication: ENV['SMTP_AUTHENTICATION'],
      user_name: ENV['SENDGRID_USERNAME'] || ENV['MAILGUN_SMTP_LOGIN'] || ENV['MANDRILL_USERNAME'],
      password: ENV['SENDGRID_PASSWORD'] || ENV['MAILGUN_SMTP_PASSWORD'] || ENV['MANDRILL_APIKEY'],
      domain: ENV['SMTP_DOMAIN'],
      enable_starttls_auto: true
    }
    config.action_mailer.preview_path = "#{Rails.root}/lib/mailer_previews"

    config.assets.precompile += %w( es5-shim.js )

    config.middleware.use PDFKit::Middleware, :print_media_type => true
  end
  def self.table_name_prefix
    'scheduler_'
  end
end
