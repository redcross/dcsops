class ActionView::Template::Handlers::Ical
  def call(template)
    <<-RUBY_CODE
    RiCal.Calendar{|cal|#{template.source}
    }.to_s
    RUBY_CODE
  end 
end

ActionView::Template.register_template_handler(:ical, ActionView::Template::Handlers::Ical.new)