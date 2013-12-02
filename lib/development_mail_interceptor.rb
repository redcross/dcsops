class DevelopmentMailInterceptor

  def self.delivering_email(message)
    message.perform_deliveries = false
    message.subject = "(#{message.to}) #{message.subject}"
    message.to = ENV['MAIL_DESTINATION']
  end
end