module Vc
  class DisasterManagement < Client

    def get_active_disasters
      response = self.get '/', query: {nd: "vms_form_5266"}
      dom = Nokogiri::HTML(response.body)
      select = dom.css "select#incident_id"
      raise Vc::QueryTool::QueryRetrievalException, "Could not find disaster list" unless select.present?

      options = select.css "option[value]"
      disasters = options.map do |node|
        next unless (value=node.attr('value')).present?
        components = node.text.strip.split(" ", 2)
        { 
          vc_incident_id: value.to_i, 
          dr_number: components.first.gsub('-20', '-'),
          name: components.last
        }
      end.compact
    end

    def get_local_disasters
      response = self.post '/', format: :json, body: {html: 'xmlhttp-vms_incident_national_incident_listing', page: 1, rp: 150}
    
      body = JSON.parse response.body
      body['rows'].map do |row|
        row = row['cell']
        {
          vc_incident_id: row[0],
          dr_number: row[1].gsub('-20', '-'),
          name: row[2].strip,
          level: row[3],
          start_date: parse_date(row[5]),
          end_date: parse_date(row[6]),
          status: row[7],
          description: row[9].strip
        }
      end
    end

    def parse_date date
      date.blank? ? nil : Date.strptime(date, "%m-%d-%Y")
    end

  end
end
