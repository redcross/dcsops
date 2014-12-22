class ::PersonTypeaheadInput < TypeaheadInput
  self.javascript_controller_name = "PersonTypeaheadController"

  def field_html
    field_tag = template.text_field_tag(method.to_s + "_text", text_value, input_html_options.merge({id: input_html_options[:id] + '_text', autocomplete: 'off', class: "form-control"}))

    builder.hidden_field(:"#{method}_id", input_html_options) <<
    if include_clear?
      template.content_tag( :div, class: 'input-group') do
        field_tag <<
        clear_html 
      end
    else
      field_tag
    end <<
    script_html
  end

  def text_value
    @text_value ||= case val = options[:text_value]
    when Symbol then builder.object.send val
    when String then val
    when Proc then val.call builder.object
    else object.send(method).try(:full_name)
    end
  end

  def include_clear?
    options[:clear].present?
  end

  def clear_html
    if include_clear?
      template.content_tag(:button, 'Clear', class: 'btn btn-sm input-group-addon', data: {clear_typeahead: method.to_s})
    else
      ""
    end
  end
end