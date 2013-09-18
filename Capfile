load 'deploy'
# Uncomment if you are using Rails' asset pipeline
load 'deploy/assets'
load 'config/deploy' # remove this line to skip loading any of the default tasks

require "rvm/capistrano"
require 'bundler/capistrano'

set :rvm_ruby_string, :local              # use the same ruby as used locally for deployment
set :rvm_autolibs_flag, "read-only"       # more info: rvm help autolibs
set :rvm_type, :system
set :bundle_dir, ''
set :bundle_flags, '--system --quiet'

task :fix_gemfile do
  run "sed -i -e 's!git://!https://!g' #{release_path}/Gemfile.lock "
  run "sed -i -e \"s#github: '#git: 'https://github.com/#g\" #{release_path}/Gemfile"
end

before 'bundle:install', 'fix_gemfile'

# Puppet will provide rvm
before 'deploy:setup', 'rvm:install_ruby' # install Ruby and create gemset, OR: