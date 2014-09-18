class ::StringArrayInput <  Formtastic::Inputs::StringInput
  def to_html
    list = object.send(method) || Array(input_html_options[:value])
    list = list.dup

    input_wrapping do
      template.content_tag(:fieldset, class: 'choices') do
        template.content_tag(:legend, label_html, class: 'label') <<
        template.content_tag(:ol, class: 'choices-group') do
          (list + '').map do |str| 
            opts = input_html_options
            opts.merge placeholder: 'Add County' if str.blank?
            template.content_tag :li, template.text_field_tag("#{builder.object_name}[#{method}][]", str, opts)
          end.reduce(&:<<)
        end
      end
    end
  end
end