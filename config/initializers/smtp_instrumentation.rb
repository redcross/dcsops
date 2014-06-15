Mail::SMTP.class_eval do
  add_method_tracer :deliver!, 'External/#{settings[:address]}/Net::SMTP'
end
