require 'base64'

class Incidents::ImportController < ApplicationController
  include ActionController::Live

  skip_before_filter :require_valid_user!, only: :import_cas
  protect_from_forgery except: [:import_cas]
  before_filter :validate_import_secret

  def import_cas
    @stream = true

    head :ok and return if request.head? 

    importer = case params[:version]
    when "1" then Incidents::CasImporter.new
    else raise "Unknown import version #{params[:version]}"
    end

    response.stream.write "->" if @stream
    puts "Beginning Import"

    case params[:provider]
    when 'mandrill'
      json = JSON.parse( params[:mandrill_events])
      json.each do |evt|

        raise "Unknown event type '#{evt['event']}'" unless evt['event'] == 'inbound'
        msg = evt['msg']

        chapter = Roster::Chapter.where(code: msg['subject']).first
        if chapter

          msg['attachments'].each do |attach_name, attach|
            io = StringIO.open(Base64.decode64 attach['content'])
            i = 0
            importer.import_data(chapter, io) do |step|
              i = i + 1
              if (i % 10) == 0
                response.stream.write '.' if @stream
                puts "Importing attachment #{i} @ #{step}..."
              end
            end
          end

        else
          response.stream.write "Couldn't find chapter '#{msg['subject']}'\n\n" if @stream
        end
      end
    else
      raise "Unknown import provider"
    end

    puts "Complete"
    head :ok unless @stream
  rescue Exception => e
    capture_exception(e)
    response.stream.write "Exception:\n"
    response.stream.write e.to_s
    puts e.to_s
    puts e.backtrace.join("\n")
    raise e
  ensure
    response.stream.close if @stream
  end

  private

  def validate_import_secret
    raise CanCan::AccessDenied unless params[:import_secret] == ENV['MAILER_IMPORT_SECRET']
  end
end
