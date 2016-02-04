ActiveSupport.on_load :connect_controller do
  skip_before_filter :require_valid_user!
  skip_before_filter :require_active_user!
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

  rsa_key = OpenSSL::PKey::RSA.new
  name = OpenSSL::X509::Name.parse("CN=dcsops.dev/DC=dcsops")
  cert = OpenSSL::X509::Certificate.new()
  cert.version = 2
  cert.serial = 0
  cert.not_before = Time.new()
  cert.not_after = cert.not_before + (60*60*24*365)
  cert.public_key = rsa_key.public_key
  cert.subject = name
  cert.issuer = name
  cert.sign rsa_key, OpenSSL::Digest::SHA1.new()

  pass_phrase = "pass-phrase"
  private_key = rsa_key.export(OpenSSL::Cipher::Cipher.new("AES-128-CBC"), pass_phrase)
  certificate = cert.to_pem

  self.jwt_issuer = Rails.env.development?           ? "https://localhost" : ENV['OPENID_ISSUER']
  self.private_key = Rails.env.development?          ? private_key         : ENV['OPENID_KEY']
  self.private_key_password = Rails.env.development? ? pass_phrase         : ENV['OPENID_PASSPHRASE']
  self.certificate = Rails.env.development?          ? certificate         : ENV['OPENID_CERTIFICATE']

  self.account_last_login = -> person { person.last_login }
  self.account_attributes = -> person, keys, scopes {
    UserInfoRenderer.new(person, keys, scopes).to_hash
  }
end


OpenIDConnect.logger = WebFinger.logger = SWD.logger = Rack::OAuth2.logger = Rails.logger
OpenIDConnect.debug!

SWD.url_builder = WebFinger.url_builder = URI::HTTP if Rails.env.development?