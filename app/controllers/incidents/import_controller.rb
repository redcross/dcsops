class Incidents::ImportController < ApplicationController
  include ActionController::Live
  include MailImportController
  newrelic_ignore_apdex

  skip_before_filter :require_valid_user!, only: :import_cas
  #protect_from_forgery except: [:import_cas]
  #before_filter :validate_import_secret

  import_handler :import_cas
  def import_cas_handler(message, attach_name, attach, content)

    importer = case params[:version]
    when "1" then Incidents::CasImporter.new
    else raise "Unknown import version #{params[:version]}"
    end

    chapter = Roster::Chapter.where(code: message['subject']).first
    if chapter
      io = StringIO.open(content)
      self.import_errors = importer.import_data(chapter, io) do |step|
        self.import_num_rows += 1
        if (self.import_num_rows % 10) == 0
          response.stream.write '.' if @stream
          msg = "Importing attachment #{self.import_num_rows} @ #{step}..."

          puts msg
          self.import_log << msg + "\n"
        end
      end
    else
      puts "Chapter #{message['subject']} not found"
      raise "Chapter Not found #{message['subject']}"
    end
  end

end
