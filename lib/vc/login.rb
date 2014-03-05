module Vc
  class Login
    include HTTParty
    base_uri "https://volunteerconnection.redcross.org"
    default_timeout 25
    #debug_output

    class InvalidCredentials < StandardError; end

    def self.get_user username, password
      client = self.new username, password
      client.query

    end

    def initialize username, password
      @username, @password = username, password
    end

    def query
      body = login_request
      extract_data body
    end

    def login_request
      response = self.class.post '/', body: {user: @username, password: @password, fail: 'login', login: 'Login', succeed: 'profile', nd: 'profile'}

      response.body
    end

    def extract_data body
      account_id = extract_account_id body
      raise InvalidCredentials unless account_id

      dom = Nokogiri::HTML(body)

      [
        {vc_id: account_id.to_i},
        {dro_history: extract_dro_history(body, dom)},
        extract_member_info(body, dom)
      ].reduce(&:merge)
    end

    def extract_account_id body
      matches = body.scan(/<a href='\/\?nd=profile_edit&account_id=(\d+)[^']*'>/)
      matches && matches.count > 0 && matches.first[0]
    end

    def extract_member_info body, dom
      block = dom.css(".block > .block_body > .block_main")
      name = block.css("h3").text
      data = block.css("p").first
      lines = data.children.select(&:text?).map{|node| node.text.strip }

      first_name, last_name = name.split /\s+/, 2
      city, state, zip = parse_csz lines[2]
      {
        first_name: first_name,
        last_name: last_name,
        address1: lines[0],
        address2: lines[1],
        city: city,
        state: state,
        zip: zip,
        email: lines[4],
        vc_member_number: lines[5].scan(/Member#: (\d+)/).first[0].to_i
      }
    end

    def extract_dro_history body, dom
      table = dom.css "#dro_history__since_march_2013_ table tbody tr"
      table.map do |row|
        cols = row.css '> td'
        {
          incident_name: process_col(cols[0]),
          assign_date: parse_date(process_col(cols[1])),
          release_date: parse_date(process_col(cols[2])),
          gap: process_col(cols[3]),
          qualifications: process_col(cols[4])
        }
      end
    end

    def process_col dom
      str = dom.text.strip
      str.present? ? str : nil
    end

    def parse_date str
      return nil unless str

      Date.strptime str, "%m-%d-%Y"
    end

    def parse_csz line
      matches = line.scan(/([\w\s]+),\s*(\w{2})\s*(\d{5})/).first
      [matches[0], matches[1], matches[2]]
    end

  end
end