require 'digest/md5'

class Roster::ImportController < ApplicationController
  include ActionController::Live
  include MailImportController
  newrelic_ignore

  skip_before_filter :require_valid_user!, only: :import_vc

  import_handler :import_vc
  def import_vc_handler(message, attach_name, attach, content)
    @stream = true

    importer = case params[:version]
    when "1" then Roster::VcImporter.new
    when "2" then Roster::VcPositionsImporter.new
    else raise "Unknown import version #{params[:version]}"
    end

    subject = message['subject']
    chapter_code = subject.split("-")[0]
    chapter = Roster::Chapter.where(code: chapter_code).first

    io = StringIO.open(content)
    self.import_errors = importer.import_data(chapter, io) do |step|
      self.import_num_rows += 1
      if (self.import_num_rows % 10) == 0
        response.stream.write '.' if @stream
        msg = "Importing attachment #{self.import_num_rows} @ #{step}..."
        puts msg
        self.import_log << msg
        self.import_log << "\n"

        extend_timeout
      end
    end

  ensure
    response.stream.close if @stream
  end

end
