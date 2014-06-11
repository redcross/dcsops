module Cas
  class Client
    class InvalidCredentials < StandardError; end
    class Unauthenticated < StandardError; end
    class OtherSessionsActive < StandardError; end

    include HTTParty
    headers "User-Agent" => "Mozilla/5.0 (Macintosh; Intel Mac OS X 10_9_2) AppleWebKit/537.75.14 (KHTML, like Gecko) Version/7.0.3 Safari/537.75.14"
    attr_reader :hostname, :username, :password, :logger
    attr_accessor :cookies

    def initialize(hostname, username, password, logger=Rails.logger)
      @hostname = hostname
      @username = username
      @password = password
      @logger   = logger
    end

    def request method, url, opts={}
      login
      rescue_from_expired_session do
        opts[:cookies] = cookies
        resp = self.class.send method, "https://#{hostname}#{url}", opts
        check_response resp
      end
    end

    def get url, opts={}
      request :get, url, opts
    end

    def post url, opts={}
      request :post, url, opts
    end

    def check_response resp
      if resp.code == 401
        raise Unauthenticated
      end
      if resp.body.include? 'logout_other_sessions'
        raise OtherSessionsActive
      end
      resp
    end

    def rescue_from_expired_session
      yield
    rescue Unauthenticated
      clear_cookies
      login!
      yield
    rescue OtherSessionsActive
      resp = clear_other_session!
      check_response resp
      yield
    end

    def login
      login! unless self.cookies
    end

    def cache_key
      Digest::SHA1.hexdigest([hostname, username, password].join "-")
    end

    def clear_cookies
      Rails.cache.delete cache_key
    end

    def cookies
      Rails.cache.read(cache_key)
    end

    def save_cookies resp
      current_cookies = cookies
      current_cookies ||= HTTParty::CookieHash.new
      resp.headers.get_fields('Set-Cookie').each {|h| current_cookies.add_cookies h}
      Rails.cache.write cache_key, current_cookies
    end

    def clear_other_session!
      resp = self.class.post "https://#{hostname}/zf/auth/clearsessions", body: {logout_other_sessions: 'Logout Other Sessions'}, cookies: cookies
      save_cookies resp
      resp
    end

    def login!
      logger.info "Logging in with user #{username}"
      resp = self.class.post "https://#{hostname}/zf/auth/login", body: {username: username, password: password, login: 'Login', Login_js: 'Login'}

      if resp.body.include? "logout_other_sessions"
        save_cookies resp
        resp = clear_other_session!
      end

      if resp.body.include? "verified.js"
        save_cookies resp
      else
        raise InvalidCredentials
      end

      true
    end

    def events
      @events ||= Events.new(self)
    end
  end
end
