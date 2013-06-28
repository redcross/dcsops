class ::TimeFieldInput <  FormtasticBootstrap::Inputs::StringInput
  include ActionView::Helpers::TextFieldDateHelper
  def initialize(*opts)
    #opts.last[:prepend] = "<i class='icon-calendar'></i>".html_safe
    #opts.last[:append] = "<button class='btn datepicker-today'>Today</button>".html_safe
    super *opts
  end

  #def input_html_options
  #  super.merge("data-provide" => "datepicker", "data-date-format" => "yyyy-mm-dd", "data-autoclose" => "true")
  #end

  def to_html
    bootstrap_wrapping do
      template.tag(:div) do
        "Date: " << builder.text_field( method, placeholder: 'year', "data-provide" => "datepicker", "data-date-format" => "yyyy-mm-dd", "data-autoclose" => "true", class: 'span2')
      end +

      "Time: " + builder.time_select( method)
    end
  end

  def wrapper_html_options
    super.tap do |options|
      options[:class] << " time-fields"
    end
  end
end