module EditableHelper
  def editable_select(resource, name, options, is_boolean: false, url: nil, editable: nil)
    if editable==nil
      editable = can? :update, resource
    end
    
    model_name = resource.class.model_name.param_key
    attr_name = "#{model_name}_#{name}"
    value = resource.send(name)
    if is_boolean
      value = value ? 1 : 0
    else
      value = value ? value.to_s : ""
    end
    
    url ||= send "#{model_name}_path", resource

    if editable
      content_tag(:a, "", href: "#", id: attr_name, data: {name: name, type: 'select', resource: model_name, url: url}) <<
      javascript_tag("$('##{attr_name}').editable({ source: #{options.to_json}, value: #{value.to_json} })")
    else
      current = options.detect{|opt| opt[:value] == value }
      current[:text] if current
    end
  end

  def editable_assignable_select(resource, name, *args)
    options = resource.send "assignable_#{name.to_s.pluralize}"
    options.map!{|v| {value: v, text: v.humanized}}
    editable_select(resource, name, options, *args)
  end

  def editable_string(resource, name, url: nil, editable: nil, **options)
    if editable==nil
      editable = can? :update, resource
    end
    if editable
      model_name = resource.class.model_name.param_key
      attr_name = "#{model_name}_#{name}-#{resource.id}"
      url ||= send "#{model_name}_path", resource
      link_to((resource.send(name) || ""), "#", id: attr_name, data: {name: name, type: 'text', resource: model_name, url: url}.reverse_merge(options)) <<
      javascript_tag("$('##{attr_name}').editable()")
    else
      resource.send(name)
    end
  end
end