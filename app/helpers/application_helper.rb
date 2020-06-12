module ApplicationHelper
  def has_admin_dashboard_access
    @_admin_access = current_user && (current_user.has_capability('region_config') || current_user.has_capability('region_admin'))
  end

  def current_messages
    if current_user and ENV['MOTD_ENABLED']
      @_current_messages ||= MOTD.active(current_region).to_a.select{|motd|
        motd.path_regex.nil? or motd.path_regex.match(request.fullpath)
      }
    else
      @_current_messages ||= MOTD.where(region_id: nil).to_a.select{|motd|
        motd.path_regex.nil? or motd.path_regex.match(request.fullpath)
      }
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
end
