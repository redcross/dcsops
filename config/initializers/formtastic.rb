if Rails.env.development?
  FormtasticBootstrap::Inputs.constants.map{|c| FormtasticBootstrap::Inputs.const_get(c)}.select {|c| Class === c}.each do |klass|
   klass.class_eval {
    #add_method_tracer :to_html, "Custom/Formtastic/Bootstrap/#{klass.to_s}/to_html", :metric => false, push_scope: false
    add_method_tracer :to_html, "Custom/Formtastic/Bootstrap/Input/to_html", :metric => false
  }
  end
end
