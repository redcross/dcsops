class Incidents::ImportController < ApplicationController
  skip_before_action :require_valid_user!, only: [:import_dispatch, :import]
  #before_action :validate_webhook
  protect_from_forgery except: [:import_dispatch]

  def user_for_paper_trail
    params[:action].to_s.titleize
  end

  def webhook_valid? key, url, params, signature
    data = url
    params.sort.each {|k,v| data = url + k + v}
    digest = OpenSSL::Digest::Digest.new('sha1')
    expected = Base64.encode64(OpenSSL::HMAC.digest(digest, key, data)).strip
    expected == signature
  end

  def validate_webhook
    return if request.head?

    key_env = "WEBHOOK_#{[params[:action], params[:route]].compact.map(&:to_s).join("_").upcase}_KEY"
    key = ENV[key_env]

    url = request.original_url
    signature = request.env['HTTP_X_MANDRILL_SIGNATURE']

    head :unauthorized unless webhook_valid? key, url, request.POST, signature
  end

  def import
    if request.head?
      head :ok and return
    end

    message = parsed_message

    Core::JobLog.capture(self.class.to_s + '#' + message['route']) do |logger, import_log|
      import_log.message_subject = message['subject']

      public_send("import_#{message['route']}", message, import_log)
    end

    head :ok
  end

  def import_dispatch_v1(message, import_log)
    body = message['body']
    # Todo: move this to the importer where it belongs
    matches = body.match(/Account: (\d+)/i)
    if matches
      account_number = matches[1]
      region = Roster::Region.with_directline_account_number_value(account_number).first!
    end
    region ||= Roster::Region.find(1)

    Incidents::DispatchLog.transaction do
      importer.import_data(region, body)
    end
  end

  def import_rco_id_v1(message, log)
    message['attachments'].each do |fname, attach|
      data = attach['Content']
      data = Base64.decode64 body

      puts data

      Roster::RcoIdImporter.new(data).import
    end
  end

  private

  def importer
    @importer ||= Incidents::DispatchImporter.new
  end

  def parsed_message
    {
      'route' => params[:ToFull].first[:Email].split("@").first.tr('-', '_'),
      'subject' => params[:Subject],
      'body' => params[:TextBody].gsub("\r\n", "\n"),
      'attachments' => params[:Attachments]
    }
  end

end
