class SmsEmailGroup

  def initialize(message)
    @original_message = message
    overhead_length = message.header[:from].encoded.size
    subject_length = message.header[:subject].encoded.size

    remaining = message.text_part || message.body.raw_source
    limit = 180 - overhead_length

    @collection = []
    while remaining.size > 0
      if remaining.size <= limit
        add_message remaining
        remaining = ""
      else
        split_pos = remaining.rindex /\s/, limit
        split_pos ||= limit

        new_body = remaining.slice(0, split_pos).strip
        remaining = remaining.slice(split_pos..-1)

        add_message new_body
      end
    end
  end

  attr_reader :collection, :original_message

  def deliver
    @collection.each { |message| message.deliver }
  end

  def add_message body
    msg = original_message.dup
    msg.body = body
    msg.subject = '' if @collection.size > 0
    @collection << msg
  end

  # Delegate Message-like behavior to the original message
  def method_missing method, *args
    original_message.send method, *args
  end

end