class ::BootstrapDateInput <  FormtasticBootstrap::Inputs::StringInput
  def initialize(*opts)
    opts.last[:prepend] = "<i class='fa fa-calendar'></i>".html_safe
    #opts.last[:append] = "<button class='btn datepicker-today'>Today</button>".html_safe
    super *opts
  end

  def input_html_options
    super.merge("data-provide" => "datepicker", "data-date-format" => "yyyy-mm-dd", "data-autoclose" => "true")
  end
end