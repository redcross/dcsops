class DevelopmentMailInterceptor

  def self.delivering_email(message)
    message.subject = "(#{message.to}) #{message.subject}"
    message.to = "John Laxson <jlaxson@mac.com>"
  end
end