module Vc
  class Permissions

    attr_reader :client

    def initialize(client)
      @client = client
    end

    def available_unit_config_permissions
      resp = client.get '/', query: {nd: 'vms_unit_configuration'}

      dom = Nokogiri::HTML(resp.body)

      items = dom.css('ul.cp_list li')
      items.map do |item|
        item.text.strip
      end
    end

    def has_disaster_management_permission?
      resp = client.get '/', query: {nd: 'disaster_management'}

      dom = Nokogiri::HTML(resp.body)

      dom.css('h2.page_name').text == 'Disaster Management'
    end
  end
end