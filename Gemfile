source 'https://rubygems.org'
ruby "2.1.1"

# Bundle edge Rails instead: gem 'rails', github: 'rails/rails'
gem 'rails', '~> 4.0.0'
gem 'squeel', github: 'activerecord-hackery/squeel'
gem 'puma'
gem 'rack-rewrite'

gem 'activerecord-postgresql-adapter'
gem 'activerecord-import'

gem 'sass-rails'
gem 'jquery-rails'
gem 'haml-rails'
gem "less-rails" #Sprockets (what Rails 3.1 uses for its asset pipeline) supports LESS

gem 'delayed_job_active_record'

gem 'inherited_resources'
gem 'responders'
gem 'has_scope'
gem "twitter-bootstrap-rails", '~> 2.2.8'
gem 'bootstrap-x-editable-rails'
gem "spreadsheet" # Import from excel

gem 'scrypt'
gem "authlogic", '3.4.0'

gem "ri_cal" # Ical Rendering
gem "cancan", github: 'jlaxson/cancan'
gem "ruby-openid", require: 'openid'
gem "chronic"
gem "roadie", '~> 2.4'
gem "kaminari"
gem "paper_trail", '~> 3.0'
gem "assignable_values"
gem 'credit_card_validator'
gem 'bootstrap-kaminari-views'
gem 'paperclip', '~> 4.0.0'
gem 'threach'
gem 'strongbox'

gem 'geokit'#, github: 'mikefarmer/geokit' # Found a branch that removes some weird build stuff

gem 'formtastic', '>=2.3.0rc2'
gem 'formtastic-bootstrap', '~> 2.1'
gem 'cocoon'
gem 'ransack',             github: 'ernie/ransack',            branch: 'rails-4'
gem 'activeadmin',       github: 'gregbell/active_admin'  

gem 'acts_as_flying_saucer', github: 'jlaxson/acts_as_flying_saucer', branch: 'master'
gem 'nokogiri'

# Monitoring/Alerting
gem 'sentry-raven'
gem 'hashie', '~>2.0.0'
gem 'newrelic_rpm'

gem 'httparty'
gem 'couchrest'
gem 'bitly'
gem 'aws-sdk'
gem "memcachier"
gem "dalli"

# Turbolinks makes following links in your web application faster. Read more: https://github.com/rails/turbolinks
# gem 'turbolinks'

# Build JSON APIs with ease. Read more: https://github.com/rails/jbuilder
gem 'jbuilder'

gem 'rails_12factor', group: :production

gem 'connect', github: 'jlaxson/openid-connect-engine', branch: 'master'

# Gems used only for assets and not required
# in production environments by default.
group :assets do
  
  gem 'coffee-rails', '~> 4.0'

  # See https://github.com/sstephenson/execjs#readme for more supported runtimes
  gem 'therubyracer', platforms: :ruby

  gem 'uglifier', '>= 1.0.3'
end


group :development, :test do
  gem 'rspec'
  gem 'rspec-rails'
  gem 'faker'
  gem 'zonebie'
  gem 'sqlite3'

  gem 'shoulda-matchers'
  gem 'factory_girl_rails'
  gem 'delorean'
  gem 'coveralls', require: false

  gem 'capybara', require: false
  gem 'capybara-webkit', require: false
  gem 'database_cleaner', '~> 1.0.1', require: false # Current 1.1.1 version has catastrophic issue that breaks DB adapters.  Can upgrade when fixed
  #gem 'sauce' # Quite possibly the most annoying, complex, fragile gem in existence
  gem 'parallel_tests'
end

group :development do
  gem 'autotest'
  #gem 'autotest-fsevent'
  gem 'byebug'
  gem 'unicorn'

  gem 'quiet_assets'

  gem 'capistrano'
  gem 'rvm-capistrano'
  gem 'ruby-prof'
  gem 'spring'
  gem 'spring-commands-rspec'
end

# To use ActiveModel has_secure_password
# gem 'bcrypt-ruby', '~> 3.0.0'

# Use unicorn as the app server
# gem 'unicorn'

# Deploy with Capistrano
# gem 'capistrano', group: :development

# To use debugger
# gem 'debugger'
