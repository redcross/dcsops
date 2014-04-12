module EditableHelper
  def editable_select(resource, name, options, is_boolean: false, url: nil)
    model_name = resource.class.model_name.param_key
    attr_name = "#{model_name}_#{name}"
    value = resource.send(name)
    if is_boolean
      value = value ? 1 : 0
    else
      value = value ? value.to_s : ""
    end
    
    url ||= send "#{model_name}_path", resource

    content_tag(:a, "", href: "#", id: attr_name, data: {name: name, type: 'select', resource: model_name, url: url}) <<
    javascript_tag("$('##{attr_name}').editable({ source: #{options.to_json}, value: #{value.to_json} })")
  end

  def editable_assignable_select(resource, name, *args)
    options = resource.send "assignable_#{name.to_s.pluralize}"
    options.map!{|v| {value: v, text: v.humanized}}
    editable_select(resource, name, options, *args)
  end
end