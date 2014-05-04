class ::PartnerInput
  include Formtastic::Inputs::Base
  include FormtasticBootstrap::Inputs::Base

  class TagHelper
    include ActionView::Helpers::FormTagHelper
  end

  def to_html
    builder.semantic_fields_for(method) do |builder|
      bootstrap_wrapping do
        builder.hidden_field(:partner_id, input_html_options) +
        builder.text_field(:partner_name, input_html_options.merge({id: input_html_options[:id] + '_text', value: builder.object.partner.try(:name)}))+
        script_html
      end
    end
  end

  def dom_id
    "#{super}_#{method}"
  end

  def script_html
    id = input_html_options[:id]
    filter = options[:filter] || {}
    template.javascript_tag("#{id}_typeahead = new PartnerTypeaheadController($('##{id}_text'), function(sel_id) {$('##{id}').val(sel_id)}, #{{q: filter}.to_json});")
  end

  def error_keys
    [:"#{method}.partner"]
  end

end