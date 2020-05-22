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

      @person ||= FactoryGirl.create :person
      @person.rco_id = 12345
      @person.save!
      OmniAuth.config.test_mode = true
      OmniAuth.config.mock_auth[:default] = OmniAuth::AuthHash.new({
        :uid => '12345'
      })
      visit "/"
      click_on "Log in with Red Cross Single Sign On"
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