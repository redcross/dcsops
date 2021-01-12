module Rccare
  class Client
    def client
      @client ||= Restforce.new(
        username: ENV['RCCARE_USERNAME'],
        password: ENV['RCCARE_PASSWORD'],
        security_token: ENV['RCCARE_SECURITY_TOKEN'],
        client_id: ENV['RCCARE_CLIENT_ID'],
        client_secret: ENV['RCCARE_CLIENT_SECRET'],
        host: ENV['RCCARE_HOST'])
    end

    def events event_id
      client.query("Select ID, Event_ID__c,Name, Event__c, Event_Name__c,Event_Type__c, Event_Level__c, Zip_Code__c from ARC_Event__c where Name = '#{event_id}'")
    end
  end
end
