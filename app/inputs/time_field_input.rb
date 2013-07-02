class TimeFieldInput <  FormtasticBootstrap::Inputs::StringInput
  def initialize(*opts)
    opts.last[:prepend] = "<i class='icon-calendar'></i>".html_safe
    #opts.last[:append] = "<button class='btn datepicker-today'>Today</button>".html_safe
    super *opts
  end

  def to_html
    id = input_html_options[:id]

    super +
    str = (<<-HTML
    <script>
      $("##{id}").datetimepicker({autoclose: true, todayHighlight: true, showMeridian: true});
    </script>
    HTML
    ).html_safe
  end

  def input_html_options
    super.merge("data-date-format" => "yyyy-mm-dd hh:ii", "data-autoclose" => "true",
      value: object.send(method).try(:strftime, '%Y-%m-%d %H:%M'))
  end
end