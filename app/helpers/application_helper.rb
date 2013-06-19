module ApplicationHelper
  def editable_select(resource, name, options, is_boolean: false)
    model_name = resource.class.model_name.param_key
    attr_name = "#{model_name}_#{name}"
    value = resource.send(name.to_sym)
    if is_boolean
      value = value ? 1 : 0
    else
      value ||= ""
    end
    str=<<-END
    <a href="#" id="#{attr_name}" data-name="#{name}" data-type="select" data-resource="#{model_name}" data-url="#{send "#{model_name}_path", resource}"></a>
    <script>
      $("##{attr_name}").editable({
        source: #{options.to_json},
        value: #{value.to_json}
      })
    </script>
    END
    str.html_safe
  end

  def has_admin_dashboard_access
    @_admin_access = current_user && current_user.has_role( 'chapter_config')
  end

  def current_messages
    if current_user
      @_current_messages ||= MOTD.active(current_user.chapter).to_a.select{|motd|
        motd.path_regex.nil? or motd.path_regex.match(request.fullpath)
      }
    else
      []
    end
  end
end
