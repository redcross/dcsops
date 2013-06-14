require 'digest/md5'

class Roster::ImportController < ApplicationController
  include ActionController::Live
  include MailImportController
  newrelic_ignore_apdex

  skip_before_filter :require_valid_user!, only: :import_vc

  import_handler :import_vc
  def import_vc_handler(message, attach_name, attach, content)
    @stream = true

    importer = case params[:version]
    when "1" then Roster::VcImporter.new
    when "2" then Roster::VcPositionsImporter.new
    else raise "Unknown import version #{params[:version]}"
    end

    puts attach.inspect

    puts Digest::MD5.hexdigest(content)

    subject = message['subject']
    puts subject
    chapter_code = subject.split("-")[0]
    puts chapter_code
    chapter = Roster::Chapter.where(code: chapter_code).first
    puts chapter.inspect
    #if chapter
      io = StringIO.open(content)
      i = 0
      errors = importer.import_data(chapter, io) do |step|
        i = i + 1
        if (i % 10) == 0
          response.stream.write '.' if @stream
          puts "Importing attachment #{i} @ #{step}..."
        end
      end
      puts errors.inspect
    #end

  ensure
    response.stream.close if @stream
  end

end
