class ::PersonTypeaheadInput
  include Formtastic::Inputs::Base
  include FormtasticBootstrap::Inputs::Base

  class TagHelper
    include ActionView::Helpers::FormTagHelper
  end

  def to_html
    bootstrap_wrapping do
      builder.hidden_field(:"#{method}_id", input_html_options) +
      TagHelper.new.text_field_tag(method.to_s + "_text", text_value, input_html_options.merge({id: input_html_options[:id] + '_text', autocomplete: 'off', class: "form-control"})) +
      script_html
    end
  end

  def text_value
    @text_value ||= case val = options[:text_value]
    when Symbol then builder.object.send val
    when String then val
    when Proc then val.call builder.object
    else object.send(method).try(:full_name)
    end
  end

  def script_html
    id = input_html_options[:id]

    filter = options[:filter] || {}
    <<-SCRIPT.html_safe
    <script>
    #{id}_typeahead = new PersonTypeaheadController($('##{id}_text'), 
            function(sel_id) {$('##{id}').val(sel_id)}, 
            #{{q: filter}.to_json}, 
            #{text_value.to_json})
    </script>
    SCRIPT
  end
end