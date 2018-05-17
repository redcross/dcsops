class SandboxMailInterceptor

  def self.delivering_email(message)
    message.to = ["sandbox@example.com"]
    message.subject = "*TEST* #{message.subject}"

    warning_msg = "*** THIS IS AN EXAMPLE MESSAGE FROM THE DCSOps SANDBOX SYSTEM ***\n" +
                  "*** This does not indicate your real-world schedule.            ***"

    message.body = "#{warning_msg}\n\n#{message.body}\n\n#{warning_msg}"
    Rails.logger.debug message
  end
end