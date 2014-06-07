class ::PersonTypeaheadInput
  include Formtastic::Inputs::Base
  include FormtasticBootstrap::Inputs::Base

  class TagHelper
    include ActionView::Helpers::FormTagHelper
  end

  def to_html
    case builder
    when ActiveAdmin::FormBuilder
      admin_html
    else
      bootstrap_html
    end
  end

  def admin_html
    input_wrapping do
      label_html <<
      field_html
    end
  end

  def bootstrap_html
    bootstrap_wrapping do
      field_html
    end
  end

  def field_html
    builder.hidden_field(:"#{method}_id", input_html_options) <<
    template.content_tag( :div, class: 'input-group') do
      template.text_field_tag(method.to_s + "_text", text_value, input_html_options.merge({id: input_html_options[:id] + '_text', autocomplete: 'off', class: "form-control"})) <<
      clear_html 
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

  def script_html
    id = input_html_options[:id]

    filter = options[:filter] || {}
    <<-SCRIPT.html_safe
    <script>
    #{id}_typeahead = new PersonTypeaheadController($('##{id}_text'), 
            function(sel_id) {$('##{id}').val(sel_id)}, 
            #{method.to_s.to_json},
            #{filter.to_json}, 
            #{text_value.to_json})
    </script>
    SCRIPT
  end
end