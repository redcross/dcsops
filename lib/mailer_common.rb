module MailerCommon
  #extend ActiveSupport::Concern

  #included do
    def format_address(person)
      addr = Mail::Address.new person.email
      addr.display_name = person.full_name
      addr.format
    end

    def tag(*tags)
      if headers['X-MC-Tags']
        existing_tags = headers['X-MC-Tags'].split(",")
      else
        existing_tags = []
      end

      headers['X-MC-Tags'] = (existing_tags + tags.map(&:to_s)).join(",")
    end
  #end
end