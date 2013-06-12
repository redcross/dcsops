class Incidents::ImportController < ApplicationController
  include ActionController::Live
  include MailImportController
  newrelic_ignore_apdex

  skip_before_filter :require_valid_user!, only: :import_cas
  #protect_from_forgery except: [:import_cas]
  #before_filter :validate_import_secret

  import_handler :import_cas
  def import_cas_handler(message, attach_name, attach, content)
    @stream = true

    importer = case params[:version]
    when "1" then Incidents::CasImporter.new
    else raise "Unknown import version #{params[:version]}"
    end

    chapter = Roster::Chapter.where(code: message['subject']).first
    if chapter
      io = StringIO.open(content)
      i = 0
      importer.import_data(chapter, io) do |step|
        i = i + 1
        if (i % 10) == 0
          response.stream.write '.' if @stream
          puts "Importing attachment #{i} @ #{step}..."
        end
      end
    else
      puts "Chapter #{message['subject']} not found"
      raise "Chapter Not found #{message['subject']}"
    end

  ensure
    response.stream.close if @stream
  end

end
