class Incidents::SMSClient
  def initialize(chapter)
    @chapter = chapter
  end

  def send_message(responder_message)
    return unless have_credentials?

    responder_message.direction = 'outgoing'
    responder_message.local_number = from_phone_number
    responder_message.remote_number = sms_number(responder_message.person)

    client.account.messages.create(
      :from => from_phone_number,
      :to => responder_message.remote_number,
      :body => responder_message.message
    )

    responder_message.save validate: false
  end

  protected

  def have_credentials?
    @chapter.twilio_account_sid.present? && @chapter.twilio_auth_token.present?
  end

  def from_phone_number
    @chapter.incidents_twilio_number
  end

  def client
    @client ||= Twilio::REST::Client.new @chapter.twilio_account_sid, @chapter.twilio_auth_token
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
