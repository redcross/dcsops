ActiveSupport.on_load :connect_controller do
  skip_before_action :require_valid_user!
  skip_before_action :require_active_user!
end

Connect.account_class = "Roster::Person"

Connect::Config.configure do
  begin_login do
    session[:redirect_after_login] = request.url if request.get?
    redirect_to main_app.new_roster_session_path
  end

  current_user do
    @current_user ||= begin
      session = Roster::Session.find
      session && session.person
    end
  end

  force_logout do
    session = Roster::Session.find
    session.destroy
    @current_user = nil
  end

  self.jwt_issuer             = ENV['OPENID_ISSUER']
  self.private_key            = ENV['OPENID_KEY']
  self.private_key_password   = ENV['OPENID_PASSPHRASE']
  self.certificate            = ENV['OPENID_CERTIFICATE']

  self.account_last_login = -> person { person.last_login }
  self.account_attributes = -> person, keys, scopes {
    UserInfoRenderer.new(person, keys, scopes).to_hash
  }
end


OpenIDConnect.logger = WebFinger.logger = SWD.logger = Rack::OAuth2.logger = Rails.logger
OpenIDConnect.debug!

#SWD.url_builder = WebFinger.url_builder = URI::HTTP if Rails.env.development?