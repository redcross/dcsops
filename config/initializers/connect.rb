ActiveSupport.on_load :connect_controller do
  skip_before_filter :require_valid_user!
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

  root = Rails.root.to_s + "/local/id_token/"

  self.jwt_issuer = Rails.env.development?           ? "https://localhost"             : ENV['OPENID_ISSUER']
  self.private_key = Rails.env.development?          ? File.read(root + "private.key") : ENV['OPENID_KEY']
  self.private_key_password = Rails.env.development? ? "pass-phrase"                   : ENV['OPENID_PASSPHRASE']
  self.certificate = Rails.env.development?          ? File.read(root + "cert.pem")    : ENV['OPENID_CERTIFICATE']

  self.account_last_login = -> person { person.last_login }
  self.account_attributes = -> person, keys, scopes {
    scopes = scopes.map(&:name)
    mapping = {name: :full_name, given_name: :first_name, family_name: :last_name, preferred_username: :username,
      email: :email}
    attrs = mapping.map{|key, attr_name| 
      {key => person.send(attr_name)}
    }.reduce(&:merge)

    if scopes.include? 'openid'
      attrs['chapter'] = person.chapter_id 
      attrs['active'] = person.vc_is_active
    end

    attrs
  }
end


OpenIDConnect.logger = WebFinger.logger = SWD.logger = Rack::OAuth2.logger = Rails.logger
OpenIDConnect.debug!

SWD.url_builder = WebFinger.url_builder = URI::HTTP if Rails.env.development?