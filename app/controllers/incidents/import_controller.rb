class Incidents::ImportController < ApplicationController
  include MailImportController
  newrelic_ignore

  skip_before_filter :require_valid_user!, only: [:import_dispatch]
  #protect_from_forgery except: [:import_cas]
  #before_filter :validate_import_secret

  def user_for_paper_trail
    params[:action].to_s.titleize
  end

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
