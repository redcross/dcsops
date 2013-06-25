class ImportLog < ActiveRecord::Base
  attr_accessor :start_time

  def update_from_exception(e)
    self.exception = e.class.to_s
    self.exception_message = e.message.to_s
    trace = ""
    trace << e.annoted_source_code.to_s if e.respond_to?(:annoted_source_code)
    trace << e.backtrace.first(10).join("\n  ")
    self.exception_trace = trace
  end
end
