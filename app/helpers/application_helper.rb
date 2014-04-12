module ApplicationHelper
  def editable_select(resource, name, options, is_boolean: false, url: nil)
    model_name = resource.class.model_name.param_key
    attr_name = "#{model_name}_#{name}"
    value = resource.send(name.to_sym)
    if is_boolean
      value = value ? 1 : 0
    else
      value = value ? value.to_s : ""
    end
    
    url ||= send "#{model_name}_path", resource

    str=<<-END
    <a href="#" id="#{attr_name}" data-name="#{name}" data-type="select" data-resource="#{model_name}" data-url="#{url}"></a>
    <script>
      $("##{attr_name}").editable({
        source: #{options.to_json},
        value: #{value.to_json}
      })
    </script>
    END
    str.html_safe
  end

  def editable_assignable_select(resource, name, *args)
    options = resource.send "assignable_#{name.to_s.pluralize}"
    options.map!{|v| {value: v, text: v.humanized}}
    editable_select(resource, name, options, *args)
  end

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

  def respond_to?(method)
    main_app_url_helper?(method) or super
  end

 private

  def main_app_url_helper?(method)
    (method.to_s.end_with?('_path') or method.to_s.end_with?('_url')) and main_app.respond_to?(method)
  end
end
