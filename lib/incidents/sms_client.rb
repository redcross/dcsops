class Incidents::SMSClient
  def initialize(region)
    @region = region
  end

  def send_message(responder_message)
    return unless have_credentials?

    responder_message.direction = 'outgoing'
    responder_message.local_number = from_phone_number
    responder_message.remote_number = sms_number(responder_message.person)

    client.messages.create(
      :from => from_phone_number,
      :to => responder_message.remote_number,
      :body => responder_message.message
    )

    responder_message.save validate: false
  end

  protected

  def have_credentials?
    @region.twilio_account_sid.present? && @region.twilio_auth_token.present?
  end

  def from_phone_number
    @region.incidents_twilio_number
  end

  def client
    @client ||= Twilio::REST::Client.new @region.twilio_account_sid, @region.twilio_auth_token
  end

  def format_phone(ph)
    str = ph.gsub(/[^0-9]+/, '')
    "+1#{str[0..9]}"
  end

  def sms_number(person)
    number_hash = person.phone_order(sms_only: true).first
    format_phone(number_hash[:number])
  end
end
