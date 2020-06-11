module MailerCommon
  extend ActiveSupport::Concern

  include Roadie::Rails::Automatic

  module ClassMethods
    def use_sms_relay *actions
      after_action :set_sms_delivery, only: actions
    end
  end

  def format_address(person)
    addr = Mail::Address.new person.email
    addr.display_name = person.full_name
    addr.format
  end

  def tag(*tags)
    if headers['X-MC-Tags']
      existing_tags = headers['X-MC-Tags'].split(",")
    else
      existing_tags = []
    end

    headers['X-MC-Tags'] = (existing_tags + tags.map(&:to_s)).join(",")
  end

  def sms!
    generate_alternatives(false)
    track_clicks(false)
  end

  def generate_alternatives(val)
    val = val ? 'true' : 'false'
    headers['X-MC-AutoHtml'] = val
    headers['X-MC-Autotext'] = val
  end

  def track_clicks(val)
    headers['X-MC-Track'] = (val ? 'opens,clicks' : 'none')
  end

  def sms_configuration
    return {} unless uri_str = ENV['SMS_RELAY']
    uri = URI.parse uri_str

    {
      address: uri.host,
      port: uri.port,
      authentication: :login,
      user_name: uri.user,
      password: uri.password,
      domain: 'dcsops.org',
      enable_starttls_auto: false
    }
  end

  def set_sms_delivery
    message.from = "sms@dcsops.org"
    message.subject = ''
    message.delivery_method.settings.merge! sms_configuration
  end
end