class Incidents::ImportController < ApplicationController
  include ActionController::Live
  include MailImportController
  newrelic_ignore_apdex

  skip_before_filter :require_valid_user!, only: [:import_cas, :import_deployment, :import_dispatch]
  #protect_from_forgery except: [:import_cas]
  #before_filter :validate_import_secret

  import_handler :import_cas, :import_deployment, :import_dispatch
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

  def import_deployment_handler(message, attach_name, attach, content)

    importer = case params[:version]
    when "1" then Incidents::DeploymentImporter.new
    else raise "Unknown import version #{params[:version]}"
    end

    chapter = Roster::Chapter.where(code: message['subject']).first
    if chapter
      io = StringIO.open(content)
      self.import_errors = importer.import_data(chapter, io) do |step|
        self.import_num_rows += 1
        if (self.import_num_rows % 1) == 0
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

  def import_dispatch_with_no_streaming
    @stream = false
    import_dispatch_without_no_streaming
  end
  alias_method_chain :import_dispatch, :no_streaming

  def import_dispatch_body_handler(message, body)
    importer = case params[:version]
    when "1" then Incidents::DispatchImporter.new
    else raise "Unknown import version #{params[:version]}"
    end

    chapter = Roster::Chapter.where(code: '05503').first!

    Incidents::DispatchLog.transaction do
      self.import_errors = importer.import_data(chapter, body)
    end
  end

end
