class TypeaheadInput
  include Formtastic::Inputs::Base
  include FormtasticBootstrap::Inputs::Base

  class_attribute :javascript_controller_name

  #class TagHelper
  #  include ActionView::Helpers::FormTagHelper
  #end

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
    builder.text_field(method, input_html_options)
  end

  def script_html
    id = input_html_options[:id]

    filter = options[:filter] || {}
    template.javascript_tag <<-SCRIPT
    #{id}_typeahead = new #{self.class.javascript_controller_name}($('##{id}_text'), 
            function(sel_id) {$('##{id}').val(sel_id)}, 
            #{method.to_s.to_json},
            #{filter.to_json}, 
            #{text_value.to_json})
    SCRIPT
  end
end