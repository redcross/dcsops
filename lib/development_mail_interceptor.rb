class DevelopmentMailInterceptor

  def self.delivering_email(message)
    dest = ENV['MAIL_DESTINATION']
    message.perform_deliveries = dest.present?
    message.subject = "(#{message.to}) #{message.subject}"
    message.to = dest
  end
end