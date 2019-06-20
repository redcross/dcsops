require File.expand_path("../../../lib/sandbox_mail_interceptor", __FILE__)

ActionMailer::Base.register_interceptor(SandboxMailInterceptor) if Rails.env.staging?
