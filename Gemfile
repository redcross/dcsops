source 'https://rubygems.org'
ruby "2.0.0"

# Bundle edge Rails instead: gem 'rails', github: 'rails/rails'
gem 'rails', '~> 4.0.0'
gem 'squeel', github: 'ernie/squeel'
gem 'puma'

gem 'activerecord-postgresql-adapter'
gem 'activerecord-import'

gem 'sass-rails',   '~> 4.0.0.rc1'
gem 'jquery-rails'
gem 'haml-rails'
gem "less-rails" #Sprockets (what Rails 3.1 uses for its asset pipeline) supports LESS

gem "memcachier"
gem "dalli"
gem 'rack-timeout', github: 'kch/rack-timeout'

gem 'inherited_resources'
gem 'responders'
gem 'has_scope'
gem "twitter-bootstrap-rails"
gem 'bootstrap-x-editable-rails'
gem "spreadsheet" # Import from excel
gem "authlogic"
gem "ri_cal" # Ical Rendering
gem "cancan", github: 'jlaxson/cancan'
gem "ruby-openid", require: 'openid'
gem "chronic"
gem "roadie", github: 'Mange/roadie'
gem "kaminari"
gem "paper_trail", github: 'airblade/paper_trail'
gem "assignable_values"

gem 'geokit', github: 'mikefarmer/geokit' # Found a branch that removes some weird build stuff

gem 'formtastic', '>=2.3.0rc2'
gem 'formtastic-bootstrap'
gem 'cocoon', github: 'nathanvda/cocoon'
gem 'ransack',             github: 'ernie/ransack',            branch: 'rails-4'
gem 'activeadmin',       github: 'jlaxson/active_admin', branch: 'rails4' # github: 'akashkamboj/active_admin', branch: 'rails4' # 

gem 'acts_as_flying_saucer', github: 'jlaxson/acts_as_flying_saucer', branch: 'master'
gem 'nokogiri'

# Monitoring/Alerting
gem 'sentry-raven'
gem 'newrelic_rpm'

gem 'httparty'
gem 'couchrest'

# Turbolinks makes following links in your web application faster. Read more: https://github.com/rails/turbolinks
# gem 'turbolinks'

# Build JSON APIs with ease. Read more: https://github.com/rails/jbuilder
gem 'jbuilder', '~> 1.0.1'

gem 'rails_12factor', group: :production

# Gems used only for assets and not required
# in production environments by default.
group :assets do
  
  gem 'coffee-rails', '~> 4.0.0.rc1'

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
  gem 'selenium-webdriver', require: false
  gem 'database_cleaner', '~> 1.0.1', require: false # Current 1.1.1 version has catastrophic issue that breaks DB adapters.  Can upgrade when fixed
  gem 'sauce', '~> 3.0.4'
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
end

# To use ActiveModel has_secure_password
# gem 'bcrypt-ruby', '~> 3.0.0'

# Use unicorn as the app server
# gem 'unicorn'

# Deploy with Capistrano
# gem 'capistrano', group: :development

# To use debugger
# gem 'debugger'
