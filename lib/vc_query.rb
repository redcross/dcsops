class VcQuery
  include HTTParty

  base_uri 'https://volunteerconnection.redcross.org'
  headers "User-Agent" => "Mozilla/5.0 (Macintosh; Intel Mac OS X 10_8_4) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/29.0.1547.65 Safari/537.36"
  #debug_output if Rails.env.development?

  attr_accessor :cookies
  attr_accessor :username, :password
  attr_accessor :query_list
  attr_accessor :logger

  def self.get_deployments(chapter)
    ImportLog.capture(self.to_s, "GetDeployments-#{chapter.id}") do |logger|
      query = self.new chapter.vc_username, chapter.vc_password
      file = query.get_disaster_query '62797', '2757948', prompt0: [chapter.name].to_json
      StringIO.open file.body do |io|
        Incidents::DeploymentImporter.new.import_data(chapter, io)
      end
    end
  end

  def initialize(user, pass)
    self.username = user
    self.password = pass
    self.logger = Rails.logger
  end

  def login
    logger.info "Logging in with user #{username}"
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

  def execute_query name
    login unless self.cookies
    get_query_list# unless self.query_list

    qid = self.query_list[name]
    raise "Couldn't find query #{name}" unless qid
    exception = nil

    3.times do 
      begin
        logger.info "Executing query #{name}"
        return self.get_query_params qid
      rescue QueryRetrievalException => e
        exception = e
      end
    end

    raise exception if exception
  end

  def get_query_list
    login unless self.cookies
    logger.info "Getting query list..."
    resp = self.class.get '/', query: {nd: 'vms_unit_query_list'}, cookies: self.cookies

    page = Nokogiri::HTML(resp.body)
    list = {}
    page.css('a.callquery[rel]').each do |node|
      list[node.text] = node.attr 'rel'
    end

    self.query_list = list
    logger.info "Done: #{list.inspect}"
  end

  def get_query_params(query_id)
    logger.info "Getting query params for id=#{query_id}"
    resp = self.class.post '/', body: {html: 'xmlhttp-vms_submit_query', query_id: query_id}, cookies: self.cookies
    page = Nokogiri::HTML(resp.body)

    qid = page.xpath("//input[@name='qsql_id']/@value").text
    qname = page.xpath("//input[@name='qname']/@value").text

    logger.debug resp.inspect

    get_query_file(qid, qname)
  end

  def get_query_file(query_id, query_name)
    raise QueryRetrievalException.new("Invalid query params qid=#{query_id} name=#{query_name}") unless query_id.present? and query_name.present?

    login unless self.cookies
    logger.info "Getting query sql for qid=#{query_id} name=#{query_name}"
    resp = self.class.post '/', query: {nd: 'vms_query_report'}, body: {nd: 'vms_query_report', qsql_id: query_id, name: query_name, qname: query_name, uweprefix: "qsql.insertTempQueryFromQid(#{query_id},'#{query_name}')"}, cookies: self.cookies
  
    page = Nokogiri::HTML(resp.body)
    form = page.css('form#excel_download')
    
    params = {
      autodownload: form.xpath("//input[@name='autodownload']/@value").text,
      sql: form.xpath("//input[@name='sql']/@value").text
    }

    logger.info "Have sql, requesting export"
    resp = self.class.post '/', body: params, cookies: self.cookies
    return resp.body
  end

  class QueryRetrievalException < Exception; end
end