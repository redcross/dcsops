class ImportLog < ActiveRecord::Base
  attr_accessor :start_time

  class MultiLogger
    def initialize *loggers
      @loggers = loggers
    end

    def method_missing *args, &blk
      @loggers.each {|l| l.send *args, &blk }
    end

    def respond_to_missing? *args
      @loggers.all? {|l| l.respond_to? *args }
    end
  end

  def self.capture(controller, name)
    log = self.create! controller: controller, name: name, start_time: Time.now, num_rows: 0
    
    result = nil
    string = StringIO.new "", "a"
    string_logger = Logger.new string
    string_logger.level = 1
    stdout_logger = Logger.new(STDOUT)
    stdout_logger.level = 0
    logger = MultiLogger.new string_logger, stdout_logger

    begin
      result = yield(logger, log)

      log.result = 'success'
    rescue => e
      log.result = 'exception'
      log.update_from_exception(e)
      raise e
    ensure
      log.runtime = (Time.now - log.start_time)
      log.log = string.string
      log.save!
    end
    

    return result

  end

  def row!
    self.num_rows = self.num_rows + 1
  end

  def update_from_exception(e)
    self.exception = e.class.to_s
    self.exception_message = e.message.to_s
    trace = ""
    trace << e.annoted_source_code.to_s if e.respond_to?(:annoted_source_code)
    trace << e.backtrace.first(10).join("\n  ")
    self.exception_trace = trace
  end
end
