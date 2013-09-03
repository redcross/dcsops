class VcQuery
  include HTTParty

  base_uri 'https://volunteerconnection.redcross.org'
  debug_output

  attr_accessor :cookies
  attr_accessor :username, :password

  def self.get_deployments(chapter)
    log = ImportLog.create! controller: self.to_s, name: "GetDeployments", start_time: Time.now

    query = self.new chapter.vc_username, chapter.vc_password
    file = query.get_disaster_query '62797', '2757948', prompt0: [chapter.name].to_json
    StringIO.open file.body do |io|
      Incidents::DeploymentImporter.new.import_data(chapter, io)
    end

    log.result = 'success'
    log.runtime = (Time.now - log.start_time)
    log.save!
  rescue => e
    log.result = 'exception'
    log.update_from_exception(e)
    log.runtime = (Time.now - log.start_time)
    log.save!

    raise e
  end

  def initialize(user, pass)
    self.username = user
    self.password = pass
  end

  def login
    resp = self.class.post '/', body: {user: username, password: password, fail: 'login', login: 'Login', succeed: 'm_home', nd: 'm_home'}

    self.cookies = HTTParty::CookieHash.new
    resp.headers.get_fields('Set-Cookie').each {|h| self.cookies.add_cookies h}
  end

  def get_disaster_query(query_id, return_jid, params={})
    login unless self.cookies
    resp = self.class.post '/', body: {nd: 'clearreports_auth', init: 'xls', return_jid: return_jid, query_id: query_id}.merge(params), cookies: self.cookies

    matches = /<a href="([^">]+)">/.match resp.body
    file_path = matches[1]

    file = self.class.get file_path, cookies: self.cookies
  end

end