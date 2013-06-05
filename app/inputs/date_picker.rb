class DatePickerInput <  Formtastic::Inputs::StringInput
  def input_html_options
    super.merge("data-provide" => "datepicker", class: "test")
  end
end