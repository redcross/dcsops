module MailImportController
  extend ActiveSupport::Concern

  included do
    before_filter :validate_import_secret

    def validate_import_secret
      raise CanCan::AccessDenied unless params[:import_secret] == ENV['MAILER_IMPORT_SECRET']
    end
  end

  module ClassMethods
    def import_handler(method, &handler_block)
      protect_from_forgery except: [method]

      attr_accessor :import_log, :import_num_rows, :import_errors

      define_method method do
        head :ok and return if request.head? 

        @stream = true

        Raven::Context.clear! # Raven will try to get data from rack, which will die since we stream these...

        @log = ImportLog.create! controller: self.class.to_s, name: method.to_s, url: request.url, start_time: Time.now
        
        response.stream.write "Parsing..." if @stream

        begin
          case params[:provider]
          when 'mandrill'
            # Todo: Validate Sig
            json = JSON.parse( params[:mandrill_events])
            json.each do |evt|
              raise "Unknown event type '#{evt['event']}'" unless evt['event'] == 'inbound'

              message = evt['msg']
              @log.update_attribute :message_subject, message['subject']

              message['attachments'].each do |name, attach|
                @log.update_attribute :file_name, name

                content = Base64.decode64(attach['content'])
                @log.update_attribute :file_size, content.length

                self.import_log = ""
                self.import_num_rows = 0

                self.send(:"#{method}_handler", message, name, attach, content)
              end
            end
          else
            raise "Unknown Mail Provider #{params[:provider]}"
          end

          @log.num_rows = self.import_num_rows
          @log.result = 'success'
          @log.log = self.import_log
          @log.import_errors = self.import_errors.to_s
          @log.runtime = (Time.now - @log.start_time)
          @log.save!

        rescue => e
          @log.num_rows = self.import_num_rows
          @log.result = 'exception'
          @log.log = self.import_log
          @log.import_errors = self.import_errors.to_s
          @log.exception = e.class.to_s
          @log.exception_message = e.message.to_s
          trace = ""
          trace << e.annoted_source_code.to_s if e.respond_to?(:annoted_source_code)
          trace << e.backtrace.first(10).join("\n  ")
          @log.exception_trace = trace
          @log.runtime = (Time.now - @log.start_time)
          @log.save!
          puts @log.inspect

          Raven.capture_exception(e)
          raise e
        ensure
          response.stream.close if @stream
        end
      end

    end

  end
end