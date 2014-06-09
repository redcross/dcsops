module Vc
  class Client
    include HTTParty
    class InvalidCredentials < StandardError; end

    base_uri 'https://volunteerconnection.redcross.org'
    headers "User-Agent" => "Mozilla/5.0 (Macintosh; Intel Mac OS X 10_8_4) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/29.0.1547.65 Safari/537.36"
    debug_output if Rails.env.development?

    attr_accessor :cookies
    attr_accessor :username, :password
    attr_accessor :logger

    def initialize(user, pass, logger=Rails.logger)
      self.username = user
      self.password = pass
      self.logger = logger
    end

    def self.from_client client
      new(client.username, client.password, client.logger).tap do |new_client|
        new_client.cookies = client.cookies
      end
    end

    def login
      login! unless self.cookies
    end

    def login!
      logger.info "Logging in with user #{username}"
      resp = self.class.post '/', body: {user: username, password: password, fail: 'login', login: 'Login', succeed: 'profile', nd: 'profile'}

      # should check if we were successful...
      if resp.body.include? 'There was a problem with your login.'
        raise InvalidCredentials
      end

      self.cookies = HTTParty::CookieHash.new
      resp.headers.get_fields('Set-Cookie').each {|h| self.cookies.add_cookies h}
    end

    def get url, opts={}
      login
      self.class.get url, opts.merge({cookies: self.cookies})
    end

    def post url, opts={}
      login
      self.class.post url, opts.merge({cookies: self.cookies})
    end

    def hours
      @hours ||= Hours.new(self)
    end
  end
end
