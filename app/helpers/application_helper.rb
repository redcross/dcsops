module ApplicationHelper
  def has_admin_dashboard_access
    @_admin_access = current_user && (current_user.has_role('chapter_config') || current_user.has_role('chapter_admin'))
  end

  def current_messages
    if current_user and ENV['MOTD_ENABLED']
      @_current_messages ||= MOTD.active(current_chapter).to_a.select{|motd|
        motd.path_regex.nil? or motd.path_regex.match(request.fullpath)
      }
    else
      []
    end
  end

  def pdf_header?
    request.env['Rack-Middleware-PDFKit'].present?
  end


  def short_url(url)
    return url if Rails.env.development? # Bitly won't shorten localhost
    Rails.cache.fetch([:shorten, url]) { Bitly.client.shorten(url).short_url }
  end

  def asset_url(*args)
    "#{request.protocol}#{request.host_with_port}#{asset_path(*args)}"
  end

  def method_missing method, *args, &block
    if main_app_url_helper?(method)
      main_app.send(method, *args)
    else
      super
    end
  end

  def respond_to?(method, include_all=true)
    main_app_url_helper?(method) or super
  end

 private

  def main_app_url_helper?(method)
    (method.to_s.end_with?('_path') or method.to_s.end_with?('_url')) and main_app.respond_to?(method)
  end
end
