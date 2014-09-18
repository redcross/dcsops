class ::StringArrayInput <  Formtastic::Inputs::StringInput
  def to_html
    list = object.send(method) || Array(input_html_options[:value])
    list = list.dup

    input_name = "#{builder.object_name}[#{method}][]"
    input_tmpl = "" + template.text_field_tag(input_name, '', input_html_options)

    input_wrapping do
      template.content_tag(:fieldset, class: 'choices') do
        template.content_tag(:legend, label_html, class: 'label') <<
        template.content_tag(:ol, class: 'choices-group', data: {string_array: true, string_array_template: input_tmpl}) do
          (list + ['']).map do |str| 
            template.content_tag :li, template.text_field_tag(input_name, str, input_html_options)
          end.reduce(&:<<)
        end
      end
    end << template.javascript_tag("window.stringArrayController = window.stringArrayController || new StringArrayController()")
  end
end