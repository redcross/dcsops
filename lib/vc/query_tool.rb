module Vc
  class QueryTool < Client

    def get_disaster_query(query_id, params={})

      report_args = {nd: 'clearreports_auth', init: 'xls', query_id: query_id}.merge(params)
      logger.debug "Report args: #{report_args.inspect}"

      resp = self.post '/', body: report_args

      matches = /<a href="([^">]+)">/.match resp.body
      file_path = matches[1]

      logger.debug "Report available at: #{file_path}"

      file = self.get file_path
    end

    def execute_query name
      get_query_list

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
      logger.info "Getting query list..."
      resp = self.get '/', query: {nd: 'vms_unit_query_list'}

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
      resp = self.post '/', body: {html: 'xmlhttp-vms_submit_query', query_id: query_id}
      page = Nokogiri::HTML(resp.body)

      qid = page.xpath("//input[@name='qsql_id']/@value").text
      qname = page.xpath("//input[@name='qname']/@value").text

      logger.debug resp.inspect

      get_query_file(qid, qname)
    end

    def get_query_file(query_id, query_name)
      raise QueryRetrievalException.new("Invalid query params qid=#{query_id} name=#{query_name}") unless query_id.present? and query_name.present?

      logger.info "Getting query sql for qid=#{query_id} name=#{query_name}"
      resp = self.post '/', query: {nd: 'vms_query_report'}, body: {nd: 'vms_query_report', qsql_id: query_id, name: query_name, qname: query_name, uweprefix: "qsql.insertTempQueryFromQid(#{query_id},'#{query_name}')"}
    
      page = Nokogiri::HTML(resp.body)
      form = page.css('form#excel_download')
      
      params = {
        autodownload: form.xpath("//input[@name='autodownload']/@value").text,
        sql: form.xpath("//input[@name='sql']/@value").text
      }

      logger.info "Have sql, requesting export"
      resp = self.post '/', body: params
      return resp.body
    end

    class QueryRetrievalException < Exception; end
  end
end
