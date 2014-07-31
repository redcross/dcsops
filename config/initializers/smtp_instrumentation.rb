Mail::SMTP.class_eval do
  include NewRelic::Agent::MethodTracer
  add_method_tracer :deliver!, 'External/#{settings[:address]}/Net::SMTP'
end
