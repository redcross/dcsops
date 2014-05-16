class GoInstantClient
  include HTTParty
  base_uri "https://api.goinstant.net/v1"
  format :json
  headers({"Content-type" => "application/json"})

  def self.client
    @client ||= Rails.env.test? ? NullClient.new : new(ENV['GOINSTANT_CLIENT_ID'], ENV['GOINSTANT_CLIENT_SECRET'], ENV['GOINSTANT_APP_NAME'])
  end

  def self.sign_token uid, display_name, groups=nil
    keystr = ENV['GOINSTANT_APP_SECRET']
    return nil unless keystr
    keystr = keystr.gsub(/\s+/,'').tr('-_','+/').sub(/=+$/,'')
    key = Base64.decode64 keystr
    claims = {
      aud: 'goinstant.net',
      iss: 'dcsops.org',
      sub: uid.to_s,
      dn: display_name,
      g: Array(groups).map{|g| {id: g.to_s, dn: g}}
    }
    JWT.encode(claims, key)
  end

  def initialize(client_id, client_secret, app_name)
    @client_id = client_id
    @client_secret = client_secret
    @app_name = app_name
  end

  def send_to_channel room, channel, value
    post "/channels/#{@app_name}/#{room}/#{channel}", body: {value: value}.to_json
  end

  def create_room room_name
    post "/apps/#{@app_name}/rooms", body: {name: room_name}.to_json
  end

  protected

  def post url, opts={}
    return if Rails.env.test?
    self.class.post url, opts.merge(headers: {"Authorization" => "Bearer #{token}"})
  rescue SocketError, Net::HTTPError => e
    Raven.capture e
    nil
  end


  def token
    if @token_expires && @token_expires < DateTime.now
      @token = nil
    end
    unless @token
      resp = self.class.post '/oauth/access_token', body: {client_id: @client_id, client_secret: @client_secret}.to_json
      @token = resp.parsed_response
      @token_expires = DateTime.parse(@token['expires']) - 60
    end
    @token['token']
  end

  class NullClient
    def send_to_channel room, channel, value

    end

    def create_room room_name

    end
  end

end