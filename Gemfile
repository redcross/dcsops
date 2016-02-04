source 'https://rubygems.org'
ruby "2.1.2"
#ruby-gemset=arcdata

# Bundle edge Rails instead: gem 'rails', github: 'rails/rails'
gem 'rails', '~> 4.1.0'
gem 'squeel', '~> 1.2.1', github: 'activerecord-hackery/squeel'
gem 'puma'
gem 'rack-rewrite'

gem 'arcdata_core', github: 'redcross/arcdata_core', branch: 'master'
gem 'connect', github: 'jlaxson/openid-connect-engine', branch: 'master'

gem 'activerecord-postgresql-adapter'
gem 'activerecord-import'

gem 'sass-rails'
gem 'jquery-rails'
gem 'jquery-ui-rails'
gem 'haml-rails'
gem "less-rails" #Sprockets (what Rails 3.1 uses for its asset pipeline) supports LESS
gem "sprockets", '~> 2.11.0'

gem 'delayed_job_active_record'

gem 'inherited_resources'
gem 'responders'
gem 'has_scope'
gem "twitter-bootstrap-rails", '~> 3.1.0', github: 'seyhunak/twitter-bootstrap-rails', branch: 'bootstrap3'
gem 'bootstrap-x-editable-rails'
gem "spreadsheet" # Import from excel

gem 'scrypt'
gem "authlogic", '3.4.0'

gem "ri_cal" # Ical Rendering
gem "cancan", github: 'jlaxson/cancan'
gem "ruby-openid", require: 'openid'
gem "timeliness"
gem "roadie", '~> 2.4'
gem "kaminari"
gem "paper_trail", '~> 3.0'
gem "assignable_values"
gem 'bootstrap-kaminari-views'
gem 'paperclip', '~> 4.0.0'
gem 'threach'
gem 'dotiw', '~> 2.0'

gem 'geokit'#, github: 'mikefarmer/geokit' # Found a branch that removes some weird build stuff

gem 'formtastic', '~> 3.0'
gem 'formtastic-bootstrap', '~> 3.0', github: 'ekubal/formtastic-bootstrap'
gem 'cocoon'
gem 'polyamorous'
gem 'ransack', '~> 1.2'
gem 'activeadmin', github: 'activeadmin'
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
gem "twilio-ruby"
gem 'pubnub'

# Turbolinks makes following links in your web application faster. Read more: https://github.com/rails/turbolinks
# gem 'turbolinks'

# Build JSON APIs with ease. Read more: https://github.com/rails/jbuilder
gem 'jbuilder'

gem 'rails_12factor', group: :production
gem 'rack-zippy', group: :production

gem 'pdfkit'
gem 'wkhtmltopdf-heroku', github: 'cater2me/wkhtmltopdf-heroku', group: :production
gem 'wkhtmltopdf-binary', github: 'dwa012/wkhtmltopdf-binary', group: :development

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

  gem 'quiet_assets'

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
