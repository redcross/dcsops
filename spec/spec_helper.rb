# This file is copied to spec/ when you run 'rails generate rspec:install'
ENV["RAILS_ENV"] ||= 'test'

require 'byebug'
require 'simplecov'
require 'coveralls'

SimpleCov.formatter = SimpleCov::Formatter::MultiFormatter.new([
  SimpleCov::Formatter::HTMLFormatter,
  Coveralls::SimpleCov::Formatter
])
SimpleCov.start 'rails'

require File.expand_path("../../config/environment", __FILE__)
require 'rspec/rails'
require 'authlogic/test_case'
require 'shoulda-matchers'
require 'factory_girl_rails'
require 'delorean'
require 'faker'
require 'zonebie'
require 'capybara/rspec'
require 'capybara/rails'
require 'capybara/apparition'
require 'capybara-screenshot'
require 'capybara-screenshot/rspec'
require 'database_cleaner'
require 'paper_trail/frameworks/rspec'
require 'vcr'

Capybara.register_driver :apparition do |app|
  Capybara::Apparition::Driver.new(app, js_errors: false)
end

Capybara.default_driver = :apparition
Capybara.server_port = ENV['TEST_ENV_NUMBER'] ? (9999+ENV['TEST_ENV_NUMBER'].to_i) : 9999

# Require Formtastic Inputs
Dir[Rails.root.join("app/inputs/**/*.rb")].each { |f| require f }

# Requires supporting ruby files with custom matchers and macros, etc,
# in spec/support/ and its subdirectories.
Dir[Rails.root.join("spec/support/**/*.rb")].each { |f| require f }

PaperTrail.enabled = false

# Checks for pending migrations before tests are run.
# If you are not using ActiveRecord, you can remove this line.
ActiveRecord::Migration.maintain_test_schema!

# Load rake tasks so they can be tested.
module TempFixForRakeLastComment
  def last_comment
    last_description
  end
end
Rake::Application.send :include, TempFixForRakeLastComment

Rake.application = Rake::Application.new
Rails.application.load_tasks

RSpec.configure do |config|
  # ## Mock Framework
  #
  # If you prefer to use mocha, flexmock or RR, uncomment the appropriate line:
  #
  # config.mock_with :mocha
  # config.mock_with :flexmock
  # config.mock_with :rr
  config.expect_with :rspec do |c|
    c.syntax = [:should, :expect]
  end

  config.mock_with :rspec do |c|
    c.syntax = [:should, :expect]
  end

  # Remove this line if you're not using ActiveRecord or ActiveRecord fixtures
  # config.fixture_path = "#{::Rails.root}/spec/fixtures"

  # If you're not using ActiveRecord, or you'd prefer not to run each of your
  # examples within a transaction, remove the following line or assign false
  # instead of true.
  config.use_transactional_fixtures = true

  # If true, the base class of anonymous controllers will be inferred
  # automatically. This will be the default behavior in future versions of
  # rspec-rails.
  config.infer_base_class_for_anonymous_controllers = false

  # Run specs in random order to surface order dependencies. If you find an
  # order dependency and want to debug it, you can fix the order by providing
  # the seed, which is printed after each run.
  #     --seed 1234
  config.order = "random"

  config.include Delorean
  config.include Authlogic::TestCase

  config.include(Shoulda::Matchers::ActiveModel, type: :model)
  config.include(Shoulda::Matchers::ActiveRecord, type: :model)

  config.filter_run_excluding :type => :feature if ENV['SKIP_FEATURES']

  config.before(:suite) do
    DatabaseCleaner.strategy = :transaction
    DatabaseCleaner.clean_with(:truncation)
  end

  config.before(:suite) do
    system('rm', '-rf', File.join(Rails.root, 'coverage'))
  end

  # For Debugging mailer spec order issues
  #config.after(:all) do
  #  begin
  #    ActionMailer::Base.deliveries.should be_empty
  #  rescue
  #    puts self.class.description
  #  end
  #end

  #config.before(:each) do
  #  DatabaseCleaner.start
  #end
#
  #config.after(:each) do
  #  DatabaseCleaner.clean
  #end

  config.before(:each) do
    SimpleCov.command_name "RSpec:#{Process.pid}#{ENV['TEST_ENV_NUMBER']}"
  end
end

Zonebie.set_random_timezone

VCR.configure do |c|
  c.cassette_library_dir     = 'spec/cassettes'
  c.hook_into                :webmock
  c.default_cassette_options = { :record => :once }
  #c.debug_logger = STDERR
  c.ignore_localhost = true
  c.configure_rspec_metadata!
end

module WaitForAjax
  def wait_for_ajax
    Timeout.timeout(Capybara.default_wait_time) do
      loop until finished_all_ajax_requests?
    end
  end

  def finished_all_ajax_requests?
    page.evaluate_script('jQuery.active').zero?
  end
end

RSpec.configure do |config|
  config.include WaitForAjax, type: :feature
end
