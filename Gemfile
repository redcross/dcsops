source 'https://rubygems.org'
ruby "2.7.1"
#ruby-gemset=arcdata

# Bundle edge Rails instead: gem 'rails', github: 'rails/rails'
gem 'rails', "~> 6.0"
gem 'puma'
gem 'rack-rewrite'
gem 'pg'

gem 'arcdata_core', github: 'redcross/arcdata_core', branch: 'upgrade/rails-6'
gem 'connect', github: 'redcross/openid-connect-engine', branch: 'rails-6-upgrade'

gem 'activerecord-postgresql-adapter'
gem 'activerecord-import'

gem 'sass-rails'
gem 'jquery-rails'
gem 'jquery-ui-rails'
gem 'haml-rails'
gem "less-rails"
gem "sprockets"

gem 'delayed_job_active_record'

gem 'inherited_resources'
gem 'responders'
gem 'has_scope'
gem "twitter-bootstrap-rails"
gem 'bootstrap-x-editable-rails'
gem "spreadsheet" # Import from excel

gem 'scrypt'
gem "authlogic"

gem "omniauth-openid-connect"

gem "ri_cal" # Ical Rendering
gem "cancan", github: 'jlaxson/cancan'
gem "ruby-openid", require: 'openid'
gem "timeliness"
gem "roadie"
gem "kaminari"
gem "paper_trail"
gem "assignable_values"
gem 'bootstrap4-kaminari-views'
gem 'paperclip'
gem 'threach'
gem 'dotiw'

gem 'geokit'#, github: 'mikefarmer/geokit' # Found a branch that removes some weird build stuff

gem 'formtastic'
gem 'formtastic-bootstrap'
gem 'cocoon'
gem 'polyamorous'
gem 'ransack'
gem 'activeadmin'
gem 'nokogiri'

# Monitoring/Alerting
gem 'sentry-raven'
gem 'hashie'
gem 'newrelic_rpm'

gem 'httparty'
gem 'couchrest'
gem 'bitly'
gem 'aws-sdk'
gem "memcachier"
gem "dalli"
gem "twilio-ruby"
gem 'pubnub'

# Turbolinks makes following links in your web application faster. Read more: https://github.com/rails/turbolinks
# gem 'turbolinks'

# Build JSON APIs with ease. Read more: https://github.com/rails/jbuilder
gem 'jbuilder'

gem 'pdfkit'
gem 'wkhtmltopdf-heroku', :group => [:staging, :production]
gem 'wkhtmltopdf-binary', github: 'dwa012/wkhtmltopdf-binary', group: :development

group :staging, :production do
  gem 'rails_12factor'
end

# Gems used only for assets and not required
# in production environments by default.
group :assets do
  
  gem 'coffee-rails', '~> 4.0'

  # See https://github.com/sstephenson/execjs#readme for more supported runtimes
  gem 'therubyracer', platforms: :ruby

  gem 'uglifier', '>= 1.0.3'
end


group :test do
  gem 'rspec', '~> 3.0'
  gem 'rspec-rails'
  gem 'rspec-activemodel-mocks'
  gem 'faker'
  gem 'zonebie'
  gem 'sqlite3'

  gem 'shoulda-matchers'
  gem 'factory_girl_rails'
  gem 'delorean'
  gem 'coveralls', require: false

  gem 'capybara', require: false
  gem 'capybara-webkit', require: false
  gem 'capybara-screenshot', require: false
  gem 'database_cleaner', '~> 1.0.1', require: false # Current 1.1.1 version has catastrophic issue that breaks DB adapters.  Can upgrade when fixed
  #gem 'sauce' # Quite possibly the most annoying, complex, fragile gem in existence
  gem 'parallel_tests'

  gem 'webmock'
  gem 'vcr'
end

group :development do
  gem 'autotest'
  #gem 'autotest-fsevent'
  gem 'byebug'
  gem 'unicorn'

  gem 'http_logger'

  gem 'ruby-prof'
  gem 'spring'
  gem 'spring-commands-rspec'

  gem 'better_errors'
  gem 'binding_of_caller'
  gem 'web-console', '~> 2.0'
end

# To use ActiveModel has_secure_password
# gem 'bcrypt-ruby', '~> 3.0.0'

# Use unicorn as the app server
# gem 'unicorn'

# To use debugger
# gem 'debugger'
