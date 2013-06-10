class SandboxMailInterceptor

  def self.delivering_email(message)
    message.subject = "*TEST* #{message.subject}"

    warning_msg = "*** THIS IS AN EXAMPLE MESSAGE FROM THE ARCBADAT SANDBOX SYSTEM ***\n" +
                  "*** This does not indicate your real-world schedule.            ***"

    if message.multipart?

    else
      message.body = "#{warning_msg}\n\n#{message.body}\n\n#{warning_msg}"
    end
  end
end