require File.expand_path("../authentication", __FILE__) # Provides LoggedIn module
require_relative 'truncation_strategy'
module FeatureSpec
  extend ActiveSupport::Concern

  include LoggedIn
  include TruncationStrategy

  included do
    self.use_transactional_fixtures = false



    before(:each) do |example|
      next if example.metadata[:logged_in] == false
      secret = Rails.application.config.secret_token
      cookies = ActionDispatch::Cookies::CookieJar.new(secret)
      allow(cookies).to receive(:close!)

      allow_any_instance_of(ActionDispatch::Request).to receive(:cookie_jar){ cookies }
      allow_any_instance_of(ActionDispatch::Request).to receive(:cookies){ cookies }

      @person ||= FactoryGirl.create :person
      @person.reset_persistence_token!
      @person.save!

      cookies['roster/person_credentials'] = "#{@person.persistence_token}::#{@person.id}"
    end

    after(:each) do
      @person = nil
    end

    # For some incredibly stupid reason the Sauce gem aliases page to call 'selenium',
    # which clobbers the entire Capybara wrapper/driver system.  So, put it back and
    # hoppe this takes precedence.
    def page; Capybara.current_session; end
  end
end

RSpec.configure do |config|
  config.include Authlogic::TestCase
  config.include FeatureSpec, type: :feature
end