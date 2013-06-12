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
      define_method method do
        head :ok and return if request.head? 
        
        begin
          case params[:provider]
          when 'mandrill'
            # Todo: Validate Sig
            json = JSON.parse( params[:mandrill_events])
            json.each do |evt|
              raise "Unknown event type '#{evt['event']}'" unless evt['event'] == 'inbound'

              message = evt['msg']
              message['attachments'].each do |name, attach|
                content = Base64.decode64(attach['content'])
                self.send(:"#{method}_handler", message, name, attach, content)
              end
            end
          else
            raise "Unknown Mail Provider #{params[:provider]}"
          end

        rescue => e
          capture_exception(e)
          puts e.to_s
          puts e.backtrace.first(10).join("\n")
          raise e
        end
      end

    end

  end
end