class ::VcPositionInput < TypeaheadInput
  self.javascript_controller_name = "VcPositionTypeaheadController"

  def field_html
    super << template.content_tag(:fieldset, class: "choices") do
      template.content_tag :ol do
        template.content_tag(:li, "Matched Positions:", class: "vc-position-list")
      end
    end
  end
end