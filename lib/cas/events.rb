module Cas
  class Events
    attr_reader :client
    def initialize client
      @client = client
    end

    def find_by_event_number event_number
      resp = client.post '/zf/casevent/search', body: {search_event_number: event_number}, format: :json
      resp.parsed_response.detect{|json| json['local_event_number'].downcase == event_number.downcase}
    end
  end
end