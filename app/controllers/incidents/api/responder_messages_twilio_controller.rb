class Incidents::Api::ResponderMessagesTwilioController < ApplicationController
  skip_before_filter :require_valid_user!
  skip_before_filter :require_active_user!
  before_filter :validate_twilio_incoming
  protect_from_forgery with: :null_session

  def incoming
    body = params[:Body]
    person = find_person_by_phone params[:From]

    unless person
      respond_with_message "A person with this phone number was not found in the database." and return
    end

    message = Incidents::ResponderMessage.new chapter: chapter, person: person, message: body, local_number: params[:To], remote_number: params[:From], direction: 'incoming'
    message.save!

    reply = Incidents::ResponderMessageService.new(message).reply
    if reply.message.present?
      respond_with_message reply.message
      reply.direction = 'reply'
      reply.local_number = params[:To]
      reply.remote_number = params[:From]
      reply.save
    else
      head :no_content
    end
  end

  protected

  def respond_with_message message
    twiml = Twilio::TwiML::Response.new do |r|
      r.Message message
    end
    render text: twiml.text
  end

  def find_person_by_phone phone
    phone = phone.gsub /^\+1/, ''
    phone = "#{phone[0..2]}-#{phone[3..5]}-#{phone[6..9]}"
    Roster::Person.for_chapter(chapter).with_phone_number(phone).first
  end

  def chapter
    @chapter ||= Roster::Chapter.with_twilio_account_sid_value(params[:AccountSid]).first!
  end

  def validate_twilio_incoming
    @validator = Twilio::Util::RequestValidator.new chapter.twilio_auth_token
    if !@validator.validate(request.original_url, request.POST, request.env['HTTP_X_TWILIO_SIGNATURE'])
      render status: 403, text: 'Invalid Signature'
    end
  end
end