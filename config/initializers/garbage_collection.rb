if ENV['ENABLE_GC_PROFILER'] and (defined?(Rails::Server) || defined?(Puma::CLI))
  puts "Enabling GC Profiling in Web Instance"
  GC::Profiler.enable
end