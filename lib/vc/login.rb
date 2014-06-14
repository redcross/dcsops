module Vc
  class Login
    include HTTParty
    base_uri "https://volunteerconnection.redcross.org"
    default_timeout 25
    headers "User-Agent" => "Mozilla/5.0 (Macintosh; Intel Mac OS X 10_8_4) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/29.0.1547.65 Safari/537.36"
    #debug_output

    class InvalidCredentials < StandardError; end

    attr_accessor :cookies

    def self.get_user username, password
      client = self.new username, password
      client.query

    end

    def initialize username, password
      @username, @password = username, password
    end

    def query
      body = login_request
      attrs = ProfileParser.new(body).extract_data
      attrs.merge! EditParser.new(edit_request attrs[:vc_id]).extract_data

      to_downcase = [:phone_1_preference, :phone_2_preference, :phone_3_preference, :phone_4_preference]
      to_downcase.each {|attr| attrs[attr] = attrs[attr].try(:downcase)}

      attrs
    end

    def save_cookies resp
      self.cookies = HTTParty::CookieHash.new
      cookies = resp.headers.get_fields('Set-Cookie')
      if cookies.present?
        cookies.each {|h| self.cookies.add_cookies h}
      end
    end

    def login_request
      response = self.class.post '/', body: {user: @username, password: @password, fail: 'login', login: 'Login', succeed: 'profile', nd: 'profile'}
      save_cookies response
      response.body
    end

    def edit_request account_id
      response = self.class.get '/', cookies: self.cookies, query: {nd: 'profile_edit', account_id: account_id}
      response.body
    end

    class EditParser
      def initialize body
        @dom = Nokogiri::HTML(body)
      end

      attr_reader :dom

      def extract_uneditable_name
        first_name = dom.xpath("//label[normalize-space(text())='First Name']/following-sibling::div/text()").try :text
        last_name =  dom.xpath("//label[normalize-space(text())='Last Name']/following-sibling::div/text()").try :text
        {first_name: first_name, last_name: last_name}
      end

      def extract_data
        fields = {first_name: 'first_name', last_name: 'last_name', address1: 'mailing_address', address2: 'mailing_address2', 
                  city: 'mailing_city', state: 'mailing_state', zip: 'mailing_postal_code',
                  home_phone: 'home_phone', work_phone: 'work_phone', cell_phone: 'cell_phone', alternate_phone: 'alternate_phone', sms_phone: 'sms_number',
                  phone_1_preference: 'phone_preference_1', phone_2_preference: 'phone_preference_2',
                  phone_3_preference: 'phone_preference_3', phone_4_preference: 'phone_preference_4'}

        attrs = extract_uneditable_name
        fields.each do |key, form_attr|
          input = dom.css("##{form_attr}").first
          if input
            val = get_input_value input
            attrs[key] = val
          end
        end

        attrs
      end

      def get_input_value input
        return nil unless input
        if input.name == 'input'
          input.attr('value')
        else
          selected = input.css('option[selected]')
          if selected.present?
            selected.attr('value').text
          end
        end.try :presence
      end
    end


    class ProfileParser

      def initialize body
        @body = body
        @dom = Nokogiri::HTML(body)
      end

      attr_reader :dom

      def extract_data
        account_id = extract_account_id @body
        raise InvalidCredentials unless account_id
        [
          {vc_id: account_id.to_i},
          {dro_history: extract_dro_history(@body, dom)},
          extract_member_info(@body, dom)
        ].reduce(&:merge)
      end

      def extract_account_id body
        matches = body.scan(/<a href='\/\?nd=profile_edit&account_id=(\d+)[^']*'>/)
        matches && matches.count > 0 && matches.first[0]
      end

      def extract_member_info body, dom
        block = dom.css(".block > .block_body > .block_main")
        data = block.css("p").first
        lines = data.children.select(&:text?).map{|node| node.text.strip }

        [extract_address(lines), extract_email(lines), extract_member_number(block)].compact.reduce(&:merge)
      end

      def extract_address lines
        county_idx = lines.find_index{|l| l=~/County/i}
        if county_idx
          address_lines = lines[0..(county_idx-1)]
          city, state, zip = parse_csz address_lines.last
          return nil unless city
          {
            address1: address_lines[0],
            address2: address_lines.count >= 3 ? address_lines[1] : nil,
            city: city,
            state: state,
            zip: zip
          }
        end
      end

      def extract_email lines
        county_idx = lines.find_index{|l| l=~/County/i}
        if county_idx
          {
            email: lines[county_idx+1]
          }
        end
      end

      def extract_member_number dom
        {
          vc_member_number: dom.text.scan(/Member#:\s+(\d+)/).first[0].to_i
        }
      end

      def extract_dro_history body, dom
        table = dom.css "#dro_history__since_march_2013_ table tbody tr"
        table.map do |row|
          cols = row.css '> td'
          next nil if cols.length < 3
          {
            incident_name: process_col(cols[0]),
            assign_date: parse_date(process_col(cols[1])),
            release_date: parse_date(process_col(cols[2])),
            gap: process_col(cols[3]).gsub('-', '/'),
            qualifications: process_col(cols[4])
          }
        end.compact
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
        if matches
          [matches[0], matches[1], matches[2]]
        else
          [nil, nil, nil]
        end
      end

    end

  end
end